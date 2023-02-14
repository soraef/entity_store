import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:result_type/result_type.dart';
import 'package:todo_app/application/store/session_store/auth_store.dart';
import 'package:todo_app/domain/auth/repository.dart';
import 'package:todo_app/domain/todo/entity.dart';
import 'package:todo_app/domain/todo/id.dart';
import 'package:todo_app/domain/todo/repository.dart';

final todoUsecase = Provider(
  (ref) => TodoUsecase(
    ref.read(repoRemoteFactory),
    ref.read(authRepo),
  ),
);

class TodoUsecase with PaginationMixIn<TodoId, Todo> {
  final FirestoreRepoFactory repoFactory;
  final AuthRepo _authRepo;

  TodoUsecase(this.repoFactory, this._authRepo);

  FirestoreRepo<TodoId, Todo> get _todoRepo =>
      repoFactory.getRepo<TodoId, Todo>();

  Future<void> create(String name) async {
    final auth = await _authRepo.getAuth();
    assert(auth?.isLogin == true);

    final newTodo = Todo.create(
      name: name,
      userId: auth!.userId!,
    );

    await repoFactory.getRepo<TodoId, Todo>().save(newTodo);
  }

  Future<Result<Todo, Exception>> check(TodoId id, bool done) async {
    final auth = await _authRepo.getAuth();
    assert(auth?.isLogin == true);

    final todo = await _todoRepo.get(
      id,
      option: const GetOption(useCache: true),
    );
    if (todo.isSuccess && todo.success != null) {
      return await _todoRepo.save(todo.success!.copyWith(done: done));
    }

    return Failure(Exception("Todo Not Found"));
  }

  Future<void> delete(Todo todo) async {
    final auth = await _authRepo.getAuth();
    assert(auth?.isLogin == true);
    await _todoRepo.delete(todo);
  }

  @override
  Future<void> loadMore({
    int limit = 10,
  }) async {
    final auth = await _authRepo.getAuth();
    assert(auth?.isLogin == true);
    await cursor(
      where: (e) => e
          .where("userId", isEqualTo: auth!.userId!.value)
          .orderBy("name")
          .limit(2),
    );
  }

  @override
  bool hasMore = true;

  @override
  TodoId? latestId;

  @override
  FirestoreRepo<TodoId, Todo> get repo => _todoRepo;
}

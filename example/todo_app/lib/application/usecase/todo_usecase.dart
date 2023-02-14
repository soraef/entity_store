import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skyreach_result/skyreach_result.dart';
import 'package:todo_app/domain/auth/entity.dart';
import 'package:todo_app/domain/auth/repository.dart';
import 'package:todo_app/domain/todo/entity.dart';
import 'package:todo_app/domain/todo/id.dart';
import 'package:todo_app/domain/user/entity.dart';
import 'package:todo_app/domain/user/id.dart';
import 'package:todo_app/infrastracture/dispatcher/dispatcher.dart';
import 'package:todo_app/infrastracture/repository/repository.dart';

final todoUsecase = Provider(
  (ref) => TodoUsecase(
    ref.watch(
      source.select(
        (value) => value.get<CommonId, Auth>(CommonId.singleton())?.userId,
      ),
    ),
    ref.read(repoRemoteFactory),
    ref.read(repoInMemoryFactory),
  ),
);

class TodoUsecase with PaginationMixIn<TodoId, Todo> {
  final FirestoreRepoFactory repoFactory;
  final InMemoryRepoFactory inMemoryFactory;
  final UserId? userId;

  TodoUsecase(this.userId, this.repoFactory, this.inMemoryFactory);

  FirestoreRepo<TodoId, Todo> _todoRepo(UserId userId) {
    return repoFactory
        .fromSubCollection<UserId, User>(userId)
        .getRepo<TodoId, Todo>();
  }

  IRepo<CommonId, Auth> get _authRepo =>
      inMemoryFactory.getRepo<CommonId, Auth>();

  Future<void> create(String name) async {
    final newTodo = Todo.create(
      name: name,
      userId: userId!,
    );

    await repoFactory.getRepo<TodoId, Todo>().save(newTodo);
  }

  Future<Result<Todo, Exception>> check(TodoId id, bool done) async {
    final todo = await _todoRepo(userId!).get(
      id,
      options: const GetOptions(useCache: true),
    );
    if (todo.isOk && todo.ok != null) {
      return await _todoRepo(userId!).save(todo.ok!.copyWith(done: done));
    }

    return Result.err(Exception("Todo Not Found"));
  }

  Future<void> delete(Todo todo) async {
    await _todoRepo(userId!).delete(todo);
  }

  Future<Auth> _checkAuth() async {
    final auth = await _authRepo.getAuth();
    assert(auth?.isLogin == true);
    return auth!;
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
  FirestoreRepo<TodoId, Todo> get repo => _todoRepo(userId!);
}

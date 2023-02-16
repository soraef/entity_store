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
      entityStore.select(
        (value) => value.get<CommonId, Auth>(CommonId.singleton())?.userId,
      ),
    ),
    ref.read(repoRemoteFactory),
    ref.read(repoInMemoryFactory),
  ),
);

class TodoUsecase {
  final FirestoreRepositoryFactory repoFactory;
  final InMemoryRepositoryFactory inMemoryFactory;
  final UserId? userId;

  TodoUsecase(this.userId, this.repoFactory, this.inMemoryFactory);

  FirestoreRepository<TodoId, Todo> _todoRepo(UserId userId) {
    return repoFactory
        .fromSubCollection<UserId, User>(userId)
        .getRepo<TodoId, Todo>();
  }

  IRepository<CommonId, Auth> get _authRepo =>
      inMemoryFactory.getRepo<CommonId, Auth>();

  Future<void> create(String name) async {
    final newTodo = Todo.create(
      name: name,
      userId: userId!,
    );

    await repo.save(newTodo);
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

  Future<void> loadAll() async {
    final auth = await _authRepo.getAuth();
    assert(auth?.isLogin == true);
    await repo.list(
      Query<TodoId, Todo>().where("userId", isEqualTo: auth!.userId!.value),
    );
  }

  FirestoreRepository<TodoId, Todo> get repo => _todoRepo(userId!);
}

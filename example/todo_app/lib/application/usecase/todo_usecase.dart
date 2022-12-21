import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:result_type/result_type.dart';
import 'package:todo_app/application/store/session_store/auth_store.dart';
import 'package:todo_app/domain/todo/entity.dart';
import 'package:todo_app/domain/todo/id.dart';
import 'package:todo_app/infrastracture/loader/loader.dart';
import 'package:todo_app/infrastracture/repository/todo_repo.dart';

final todoUsecase = Provider(
  (ref) => TodoUsecase(
    ref.read(todoRepo),
    ref.read(authStore.notifier),
  ),
);

class TodoUsecase with LoaderMixIn<TodoId, Todo> {
  final TodoRepo todoRepo;
  final AuthStore authStore;

  TodoUsecase(this.todoRepo, this.authStore);

  Future<void> create(String name) async {
    assert(authStore.value.isLogin);

    final newTodo = Todo.create(
      name: name,
      userId: authStore.value.userId!,
    );

    await todoRepo.save(newTodo);
  }

  Future<Result<Todo, Exception>> check(TodoId id, bool done) async {
    assert(authStore.value.isLogin);

    final todo = await todoRepo.get(id, useStoreCache: true);
    if (todo.isSuccess && todo.success != null) {
      return todoRepo.save(todo.success!.copyWith(done: done));
    }

    return Failure(Exception("Todo Not Found"));
  }

  Future<void> delete(Todo todo) async {
    assert(authStore.value.isLogin);
    await todoRepo.delete(todo);
  }

  @override
  Future<void> loadMore() async {
    assert(authStore.value.isLogin);
    await cursor(
      collection: TodoCollection(),
      where: (e) => e
          .where("userId", isEqualTo: authStore.value.userId!.value)
          .orderBy("name")
          .limit(2),
    );
  }

  @override
  bool hasMore = true;

  @override
  TodoId? latestId;

  @override
  FirestoreList<TodoId, Todo> get repo => todoRepo;
}

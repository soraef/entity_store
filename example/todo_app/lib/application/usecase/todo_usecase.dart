import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:result_type/result_type.dart';
import 'package:todo_app/application/store/entity_store/todo_store.dart';
import 'package:todo_app/application/store/session_store/auth_store.dart';
import 'package:todo_app/domain/todo/entity.dart';
import 'package:todo_app/domain/todo/id.dart';

final todoUsecase = Provider(
  (ref) => TodoUsecase(
    ref.read(todoStore.notifier),
    ref.read(authStore.notifier),
  ),
);

class TodoUsecase {
  final TodoStore todoStore;
  final AuthStore authStore;

  TodoUsecase(this.todoStore, this.authStore);

  Future<void> create(String name) async {
    assert(authStore.value.isLogin);

    final newTodo = Todo(
      id: TodoId.create(),
      name: name,
      done: false,
      userId: authStore.value.userId!,
    );

    await todoStore.save(newTodo);
  }

  Future<Result<Todo, Exception>> check(TodoId id, bool done) async {
    assert(authStore.value.isLogin);

    final todo = await todoStore.get(id);
    if (todo.isSuccess && todo.success != null) {
      return todoStore.save(todo.success!.copyWith(done: done));
    }

    return Failure(Exception("Todo Not Found"));
  }

  Future<void> load() async {
    assert(authStore.value.isLogin);
    await todoStore.listUserTodo(authStore.value.userId!);
  }

  Future<void> delete(Todo todo) async {
    assert(authStore.value.isLogin);
    await todoStore.delete(todo);
  }
}

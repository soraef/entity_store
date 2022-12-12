import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/domain/todo/entity.dart';
import 'package:todo_app/domain/todo/id.dart';
import 'package:todo_app/infrastracture/store/riverpod_store.dart';

final todoStore = StateNotifierProvider<TodoStore, Todos>(
  (ref) => TodoStore(Todos.empty()),
);

class TodoStore extends RiverpodEntityMapStore<TodoId, Todo> {
  TodoStore(super.state);
}

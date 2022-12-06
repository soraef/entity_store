import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:result_type/result_type.dart';
import 'package:todo_app/domain/todo/entity.dart';
import 'package:todo_app/domain/todo/id.dart';
import 'package:todo_app/domain/user/id.dart';
import 'package:todo_app/infrastracture/repository/todo_repo.dart';
import 'package:todo_app/infrastracture/store/riverpod_store.dart';

final todoStore = StateNotifierProvider<TodoStore, Todos>(
  (ref) => TodoStore(Todos.empty()),
);

class TodoStore extends RiverpodStore<Todos>
    with
        GetEntitiesStore<TodoId, Todo>,
        ListEntitiesStore<TodoId, Todo, FirestoreListParams<TodoId, Todo>>,
        SaveEntitiesStore<TodoId, Todo>,
        DeleteEntitiesStore<TodoId, Todo> {
  TodoStore(super.state);

  @override
  RepositoryDelete<TodoId, Todo> get repositoryDelete => TodoRepo();

  @override
  RepositoryList<TodoId, Todo, FirestoreListParams<TodoId, Todo>>
      get repositoryList => TodoRepo();

  @override
  RepositorySave<TodoId, Todo> get repositorySave => TodoRepo();

  @override
  RepositoryGet<TodoId, Todo> get repositoryGet => TodoRepo();

  Future<Result<List<Todo>, Exception>> listUserTodo(UserId userId) async {
    return list(
      FirestoreListParams(
        collection: TodoCollection(),
        where: (ref) => ref.where("userId", isEqualTo: userId.value),
      ),
    );
  }
}

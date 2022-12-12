import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:result_type/result_type.dart';
import 'package:todo_app/domain/todo/entity.dart';
import 'package:todo_app/domain/todo/id.dart';
import 'package:todo_app/domain/user/id.dart';
import 'package:todo_app/infrastracture/dispatcher/dispatcher.dart';

final todoRepo = Provider((ref) => TodoRepo(ref.read(eventDispatcher)));

class TodoRepo extends IRepo
    with
        FirestoreGet<TodoId, Todo>,
        FirestoreSave<TodoId, Todo>,
        FirestoreUpdate<TodoId, Todo>,
        FirestoreDelete<TodoId, Todo>,
        FirestoreList<TodoId, Todo> {
  @override
  FirestoreCollection<TodoId, Todo> getCollection(TodoId id) {
    return TodoCollection();
  }

  @override
  EntityJsonConverter<TodoId, Todo> get converter => EntityJsonConverter(
        fromJson: Todo.fromJson,
        toJson: (todo) => todo.toJson(),
      );

  TodoRepo(super.eventDispatcher);

  Future<Result<List<Todo>, Exception>> listUserTodo(UserId userId) async {
    return list(
      collection: TodoCollection(),
      where: (ref) => ref.where("userId", isEqualTo: userId.value),
    );
  }
}

class TodoCollection with FirestoreCollection1<TodoId, Todo> {
  @override
  String get collection1 => "Todo";

  @override
  String toDocumentId(TodoId id) {
    return id.value;
  }
}

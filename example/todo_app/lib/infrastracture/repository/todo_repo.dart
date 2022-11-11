import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:todo_app/domain/todo/entity.dart';
import 'package:todo_app/domain/todo/id.dart';

class TodoRepo
    with
        FirestoreGet<TodoId, Todo>,
        FirestoreSave<TodoId, Todo>,
        FirestoreDelete<TodoId, Todo>,
        FirestoreList<TodoId, Todo, FirestoreListParams<TodoId, Todo>> {
  @override
  RepositoryConverter<TodoId, Todo> get converter => RepositoryConverter(
        fromJson: Todo.fromJson,
        toJson: (todo) => todo.toJson(),
      );

  @override
  FirestoreCollection<TodoId, Todo> getCollection(TodoId id) {
    return TodoCollection();
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

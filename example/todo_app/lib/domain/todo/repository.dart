import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:todo_app/domain/todo/entity.dart';
import 'package:todo_app/domain/todo/id.dart';

class TodoRepository extends SubCollectionRepository<TodoId, Todo> {
  @override
  final EntityStoreController controller;

  TodoRepository({
    required this.controller,
    required super.parentRepository,
    required super.parentDocumentId,
  });

  @override
  Todo fromJson(Map<String, dynamic> json) {
    return Todo.fromJson(json);
  }

  @override
  String toDocumentId(TodoId id) {
    return id.value;
  }

  @override
  Map<String, dynamic> toJson(Todo entity) {
    return entity.toJson();
  }

  @override
  String get collectionId => "Todo";
}

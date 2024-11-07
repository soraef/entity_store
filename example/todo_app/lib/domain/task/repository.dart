import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:todo_app/domain/task/entity.dart';
import 'package:todo_app/domain/task/id.dart';

class TaskRepository extends FirestoreSubCollectionRepository<TaskId, Task> {
  TaskRepository({
    required super.controller,
    required super.parentRepository,
    required super.parentDocumentId,
  });

  @override
  Task fromJson(Map<String, dynamic> json) {
    return Task.fromJson(json);
  }

  @override
  String idToString(TaskId id) {
    return id.value;
  }

  @override
  Map<String, dynamic> toJson(Task entity) {
    return entity.toJson();
  }

  @override
  String get collectionId => "Task";
}

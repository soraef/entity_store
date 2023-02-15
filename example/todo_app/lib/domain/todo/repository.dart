import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:todo_app/domain/todo/entity.dart';
import 'package:todo_app/domain/todo/id.dart';

final todoCollectionType = CollectionType<TodoId, Todo>.bucketing(
  fromJson: Todo.fromJson,
  toJson: (e) => e.toJson(),
  idToString: (e) => e.value,
  collectionName: "Todo",
  bucketIdToString: (Todo entity) {
    /// Bucketing Monthly
    return entity.createdAt.year.toString() + entity.createdAt.month.toString();
  },
  bucketingFieldName: "todos",
  toDocumentFields: (Todo todo) {
    return {
      "userId": todo.userId.value,
    };
  },
);

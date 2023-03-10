import 'package:entity_store_firestore/entity_store_firestore.dart';

import 'entity.dart';
import 'id.dart';

class SubTaskRepository
    extends SubCollectionBucketRepository<SubTaskId, SubTask> {
  SubTaskRepository({
    required super.controller,
    required super.parentRepository,
    required super.parentDocumentId,
  });

  @override
  SubTask fromJson(Map<String, dynamic> json) {
    return SubTask.fromJson(json);
  }

  @override
  String idToString(SubTaskId id) {
    return id.value;
  }

  @override
  Map<String, dynamic> toJson(SubTask entity) {
    return entity.toJson();
  }

  @override
  String get collectionId => "Task";

  @override
  String get bucketFieldName => "subTasks";

  @override
  String bucketIdToString(SubTask entity) {
    return entity.taskId.value;
  }
}

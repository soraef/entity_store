import 'package:entity_store/entity_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

extension type TaskId(String value) implements String {
  factory TaskId.create() {
    return TaskId(const Uuid().v4());
  }
}

class TaskIdConverter implements JsonConverter<TaskId, String> {
  const TaskIdConverter();
  @override
  TaskId fromJson(String json) {
    return TaskId(json);
  }

  @override
  String toJson(TaskId object) {
    return object.value;
  }
}

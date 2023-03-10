import 'package:entity_store/entity_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

class TaskId extends Id {
  const TaskId(String value) : super(value);

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

class TaskIdListConverter
    implements JsonConverter<List<TaskId>, List<dynamic>> {
  const TaskIdListConverter();

  @override
  List<TaskId> fromJson(List<dynamic> json) {
    return json.map((e) => TaskId(e)).toList();
  }

  @override
  List<String> toJson(List<TaskId> object) {
    return object.map((e) => e.value).toList();
  }
}

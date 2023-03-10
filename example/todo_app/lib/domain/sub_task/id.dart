import 'package:entity_store/entity_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

class SubTaskId extends Id {
  const SubTaskId(String value) : super(value);

  factory SubTaskId.create() {
    return SubTaskId(const Uuid().v4());
  }
}

class SubTaskIdConverter implements JsonConverter<SubTaskId, String> {
  const SubTaskIdConverter();
  @override
  SubTaskId fromJson(String json) {
    return SubTaskId(json);
  }

  @override
  String toJson(SubTaskId object) {
    return object.value;
  }
}

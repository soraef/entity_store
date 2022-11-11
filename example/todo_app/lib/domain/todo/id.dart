import 'package:entity_store/entity_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

class TodoId extends Id {
  const TodoId(String value) : super(value);

  factory TodoId.create() {
    return TodoId(const Uuid().v4());
  }
}

class TodoIdConverter implements JsonConverter<TodoId, String> {
  const TodoIdConverter();
  @override
  TodoId fromJson(String json) {
    return TodoId(json);
  }

  @override
  String toJson(TodoId object) {
    return object.value;
  }
}

class TodoIdListConverter
    implements JsonConverter<List<TodoId>, List<dynamic>> {
  const TodoIdListConverter();

  @override
  List<TodoId> fromJson(List<dynamic> json) {
    return json.map((e) => TodoId(e)).toList();
  }

  @override
  List<String> toJson(List<TodoId> object) {
    return object.map((e) => e.value).toList();
  }
}

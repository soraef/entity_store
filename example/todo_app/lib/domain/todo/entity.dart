import 'package:entity_store/entity_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todo_app/domain/user/id.dart';

import 'id.dart';

part 'entity.freezed.dart';
part 'entity.g.dart';

@freezed
class Todo with _$Todo implements Entity<TodoId> {
  const Todo._();
  @JsonSerializable(explicitToJson: true)
  const factory Todo({
    @TodoIdConverter() required TodoId id,
    @UserIdConverter() required UserId userId,
    required String name,
    required bool done,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}

typedef Todos = EntityMap<TodoId, Todo>;

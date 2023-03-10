// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todo_app/domain/user/id.dart';
import 'package:todo_app/infrastracture/converter/datetime_conveter.dart';

import 'id.dart';

part 'entity.freezed.dart';
part 'entity.g.dart';

@freezed
class Task with _$Task implements Entity<TaskId> {
  const Task._();
  @JsonSerializable(explicitToJson: true)
  const factory Task({
    @TaskIdConverter() required TaskId id,
    @UserIdConverter() required UserId userId,
    required String name,
    required bool done,
    @DateTimeConverter() required DateTime createdAt,
    @DateTimeConverter() required DateTime updatedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  factory Task.create({
    required UserId userId,
    required String name,
  }) {
    return Task(
      id: TaskId.create(),
      userId: userId,
      name: name,
      done: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Task update({
    String? name,
    bool? done,
  }) {
    return copyWith(
      name: name ?? this.name,
      done: done ?? this.done,
      updatedAt: DateTime.now(),
    );
  }
}

typedef Tasks = EntityMap<TaskId, Task>;

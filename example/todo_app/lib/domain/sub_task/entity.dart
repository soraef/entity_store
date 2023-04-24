import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todo_app/domain/task/id.dart';
import 'package:todo_app/domain/user/id.dart';
import 'package:todo_app/infrastracture/converter/datetime_conveter.dart';

import 'id.dart';

part 'entity.freezed.dart';
part 'entity.g.dart';

@freezed
class SubTask with _$SubTask implements Entity<SubTaskId> {
  const SubTask._();
  @JsonSerializable(explicitToJson: true)
  const factory SubTask({
    @SubTaskIdConverter() required SubTaskId id,
    @TaskIdConverter() required TaskId taskId,
    @UserIdConverter() required UserId userId,
    required String name,
    required bool done,
    @DateTimeConverter() required DateTime createdAt,
    @DateTimeConverter() required DateTime updatedAt,
  }) = _SubTask;

  factory SubTask.fromJson(Map<String, dynamic> json) =>
      _$SubTaskFromJson(json);

  factory SubTask.create({
    required TaskId taskId,
    required UserId userId,
    required String name,
  }) {
    return SubTask(
      id: SubTaskId.create(),
      taskId: taskId,
      userId: userId,
      name: name,
      done: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  SubTask complete() {
    return copyWith(
      done: true,
      updatedAt: DateTime.now(),
    );
  }

  SubTask uncomplete() {
    return copyWith(
      done: false,
      updatedAt: DateTime.now(),
    );
  }
}

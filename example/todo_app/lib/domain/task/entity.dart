// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:entity_store/entity_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todo_app/domain/sub_task/entity.dart';
import 'package:todo_app/domain/sub_task/id.dart';
import 'package:todo_app/domain/user/id.dart';
import 'package:todo_app/infrastracture/converter/datetime_conveter.dart';

import 'id.dart';

part 'entity.freezed.dart';
part 'entity.g.dart';

@freezed
class Task with _$Task implements Entity {
  const Task._();
  @JsonSerializable(explicitToJson: true)
  const factory Task({
    @TaskIdConverter() required TaskId id,
    @UserIdConverter() required UserId userId,
    required String name,
    required bool done,
    @JsonKey(defaultValue: <SubTask>[]) required List<SubTask> subTasks,
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
      subTasks: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Task complete() {
    return copyWith(
      done: true,
      subTasks: [
        for (final subTask in subTasks) subTask.complete(),
      ],
      updatedAt: DateTime.now(),
    );
  }

  Task uncomplete() {
    return copyWith(
      done: false,
      updatedAt: DateTime.now(),
    );
  }

  Task addSubTask(String name) {
    final newSubTasks = [
      ...subTasks,
      SubTask.create(taskId: id, userId: userId, name: name),
    ];
    return copyWith(
      subTasks: newSubTasks,
      done: newSubTasks.every((subTask) => subTask.done),
      updatedAt: DateTime.now(),
    );
  }

  Task removeSubTask(SubTaskId subTaskId) {
    return copyWith(
      subTasks: [
        for (final subTask in subTasks)
          if (subTask.id != subTaskId) subTask,
      ],
      updatedAt: DateTime.now(),
    );
  }

  Task completeSubTask(SubTaskId subTaskId) {
    final newSubTasks = subTasks.map((subTask) {
      if (subTask.id == subTaskId) {
        return subTask.complete();
      } else {
        return subTask;
      }
    }).toList();

    return copyWith(
      subTasks: newSubTasks,
      done: newSubTasks.every((subTask) => subTask.done),
      updatedAt: DateTime.now(),
    );
  }

  Task uncompleteSubTask(SubTaskId subTaskId) {
    final newSubTasks = subTasks.map((subTask) {
      if (subTask.id == subTaskId) {
        return subTask.uncomplete();
      } else {
        return subTask;
      }
    }).toList();

    return copyWith(
      subTasks: newSubTasks,
      done: newSubTasks.every((subTask) => subTask.done),
      updatedAt: DateTime.now(),
    );
  }

  SubTask? findSubTaskById(SubTaskId subTaskId) {
    return subTasks.firstWhereOrNull((subTask) => subTask.id == subTaskId);
  }
}

typedef Tasks = EntityMap<Task>;

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SubTask _$$_SubTaskFromJson(Map<String, dynamic> json) => _$_SubTask(
      id: const SubTaskIdConverter().fromJson(json['id'] as String),
      taskId: const TaskIdConverter().fromJson(json['taskId'] as String),
      userId: const UserIdConverter().fromJson(json['userId'] as String),
      name: json['name'] as String,
      done: json['done'] as bool,
      createdAt:
          const DateTimeConverter().fromJson(json['createdAt'] as Timestamp?),
      updatedAt:
          const DateTimeConverter().fromJson(json['updatedAt'] as Timestamp?),
    );

Map<String, dynamic> _$$_SubTaskToJson(_$_SubTask instance) =>
    <String, dynamic>{
      'id': const SubTaskIdConverter().toJson(instance.id),
      'taskId': const TaskIdConverter().toJson(instance.taskId),
      'userId': const UserIdConverter().toJson(instance.userId),
      'name': instance.name,
      'done': instance.done,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const DateTimeConverter().toJson(instance.updatedAt),
    };

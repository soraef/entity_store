// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubTaskImpl _$$SubTaskImplFromJson(Map<String, dynamic> json) =>
    _$SubTaskImpl(
      id: json['id'] as SubTaskId,
      taskId: const TaskIdConverter().fromJson(json['taskId'] as String),
      userId: const UserIdConverter().fromJson(json['userId'] as String),
      name: json['name'] as String,
      done: json['done'] as bool,
      createdAt:
          const DateTimeConverter().fromJson(json['createdAt'] as Timestamp?),
      updatedAt:
          const DateTimeConverter().fromJson(json['updatedAt'] as Timestamp?),
    );

Map<String, dynamic> _$$SubTaskImplToJson(_$SubTaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': const TaskIdConverter().toJson(instance.taskId),
      'userId': const UserIdConverter().toJson(instance.userId),
      'name': instance.name,
      'done': instance.done,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const DateTimeConverter().toJson(instance.updatedAt),
    };

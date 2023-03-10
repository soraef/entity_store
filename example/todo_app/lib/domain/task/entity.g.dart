// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Task _$$_TaskFromJson(Map<String, dynamic> json) => _$_Task(
      id: const TaskIdConverter().fromJson(json['id'] as String),
      userId: const UserIdConverter().fromJson(json['userId'] as String),
      name: json['name'] as String,
      done: json['done'] as bool,
      createdAt:
          const DateTimeConverter().fromJson(json['createdAt'] as Timestamp?),
      updatedAt:
          const DateTimeConverter().fromJson(json['updatedAt'] as Timestamp?),
    );

Map<String, dynamic> _$$_TaskToJson(_$_Task instance) => <String, dynamic>{
      'id': const TaskIdConverter().toJson(instance.id),
      'userId': const UserIdConverter().toJson(instance.userId),
      'name': instance.name,
      'done': instance.done,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const DateTimeConverter().toJson(instance.updatedAt),
    };

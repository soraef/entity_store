// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
      id: const TaskIdConverter().fromJson(json['id'] as String),
      userId: const UserIdConverter().fromJson(json['userId'] as String),
      name: json['name'] as String,
      done: json['done'] as bool,
      subTasks: (json['subTasks'] as List<dynamic>?)
              ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt:
          const DateTimeConverter().fromJson(json['createdAt'] as Timestamp?),
      updatedAt:
          const DateTimeConverter().fromJson(json['updatedAt'] as Timestamp?),
    );

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) =>
    <String, dynamic>{
      'id': const TaskIdConverter().toJson(instance.id),
      'userId': const UserIdConverter().toJson(instance.userId),
      'name': instance.name,
      'done': instance.done,
      'subTasks': instance.subTasks.map((e) => e.toJson()).toList(),
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const DateTimeConverter().toJson(instance.updatedAt),
    };

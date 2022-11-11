// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Todo _$$_TodoFromJson(Map<String, dynamic> json) => _$_Todo(
      id: const TodoIdConverter().fromJson(json['id'] as String),
      userId: const UserIdConverter().fromJson(json['userId'] as String),
      name: json['name'] as String,
      done: json['done'] as bool,
    );

Map<String, dynamic> _$$_TodoToJson(_$_Todo instance) => <String, dynamic>{
      'id': const TodoIdConverter().toJson(instance.id),
      'userId': const UserIdConverter().toJson(instance.userId),
      'name': instance.name,
      'done': instance.done,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Activity _$$_ActivityFromJson(Map<String, dynamic> json) => _$_Activity(
      id: const ActivityIdConverter().fromJson(json['id'] as String),
      name: json['name'] as String,
    );

Map<String, dynamic> _$$_ActivityToJson(_$_Activity instance) =>
    <String, dynamic>{
      'id': const ActivityIdConverter().toJson(instance.id),
      'name': instance.name,
    };

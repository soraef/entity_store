// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_WeeklyActivity _$$_WeeklyActivityFromJson(Map<String, dynamic> json) =>
    _$_WeeklyActivity(
      id: const WeeklyActivityIdConverter().fromJson(json['id'] as String),
      userId: const UserIdConverter().fromJson(json['userId'] as String),
      activities: (json['activities'] as List<dynamic>)
          .map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int,
    );

Map<String, dynamic> _$$_WeeklyActivityToJson(_$_WeeklyActivity instance) =>
    <String, dynamic>{
      'id': const WeeklyActivityIdConverter().toJson(instance.id),
      'userId': const UserIdConverter().toJson(instance.userId),
      'activities': instance.activities.map((e) => e.toJson()).toList(),
      'count': instance.count,
    };

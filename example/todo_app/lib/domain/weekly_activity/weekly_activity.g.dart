// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeeklyActivityImpl _$$WeeklyActivityImplFromJson(Map<String, dynamic> json) =>
    _$WeeklyActivityImpl(
      id: json['id'] as WeeklyActivityId,
      userId: const UserIdConverter().fromJson(json['userId'] as String),
      activities: (json['activities'] as List<dynamic>)
          .map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$$WeeklyActivityImplToJson(
        _$WeeklyActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': const UserIdConverter().toJson(instance.userId),
      'activities': instance.activities.map((e) => e.toJson()).toList(),
      'count': instance.count,
    };

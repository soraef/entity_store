// ignore_for_file: invalid_annotation_target

import 'package:entity_store/entity_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todo_app/domain/user/id.dart';
import 'package:todo_app/domain/weekly_activity/activity.dart';

part 'weekly_activity.freezed.dart';
part 'weekly_activity.g.dart';

@freezed
class WeeklyActivity with _$WeeklyActivity implements Entity<WeeklyActivityId> {
  const WeeklyActivity._();
  @JsonSerializable(explicitToJson: true)
  const factory WeeklyActivity({
    @WeeklyActivityIdConverter() required WeeklyActivityId id,
    @UserIdConverter() required UserId userId,
    required List<Activity> activities,
    required int count,
  }) = _WeeklyActivity;

  factory WeeklyActivity.fromJson(Map<String, dynamic> json) =>
      _$WeeklyActivityFromJson(json);

  factory WeeklyActivity.createNow({
    required UserId userId,
    required List<Activity> activities,
  }) {
    return WeeklyActivity(
      id: WeeklyActivityId.create(userId, DateTime.now()),
      userId: userId,
      activities: activities,
      count: activities.length,
    );
  }

  WeeklyActivity addActivity(String name) {
    return copyWith(
      activities: [
        ...activities,
        Activity(id: ActivityId.create(), name: name)
      ],
      count: count + 1,
    );
  }
}

class WeeklyActivityId extends Id {
  const WeeklyActivityId(String value) : super(value);

  /// datetimeを月曜の0時にする
  /// 例: 2021/08/01 12:00:00 -> 2021/07/26 00:00:00
  static String _getMonday(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day - dateTime.weekday + 1,
    ).toIso8601String();
  }

  factory WeeklyActivityId.create(UserId userId, DateTime dateTime) {
    return WeeklyActivityId(userId.value + _getMonday(dateTime));
  }
}

class WeeklyActivityIdConverter
    implements JsonConverter<WeeklyActivityId, String> {
  const WeeklyActivityIdConverter();
  @override
  WeeklyActivityId fromJson(String json) {
    return WeeklyActivityId(json);
  }

  @override
  String toJson(WeeklyActivityId object) {
    return object.value;
  }
}

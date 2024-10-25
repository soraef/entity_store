// ignore_for_file: invalid_annotation_target

import 'package:entity_store/entity_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

@freezed
class Activity with _$Activity implements Entity {
  const Activity._();
  @JsonSerializable(explicitToJson: true)
  const factory Activity({
    @ActivityIdConverter() required ActivityId id,
    required String name,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
}

extension type ActivityId(String value) implements String {
  factory ActivityId.create() {
    return ActivityId(const Uuid().v4());
  }
}

class ActivityIdConverter implements JsonConverter<ActivityId, String> {
  const ActivityIdConverter();
  @override
  ActivityId fromJson(String json) {
    return ActivityId(json);
  }

  @override
  String toJson(ActivityId object) {
    return object.value;
  }
}

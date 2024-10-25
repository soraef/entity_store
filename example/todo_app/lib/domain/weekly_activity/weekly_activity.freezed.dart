// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WeeklyActivity _$WeeklyActivityFromJson(Map<String, dynamic> json) {
  return _WeeklyActivity.fromJson(json);
}

/// @nodoc
mixin _$WeeklyActivity {
  WeeklyActivityId get id => throw _privateConstructorUsedError;
  @UserIdConverter()
  UserId get userId => throw _privateConstructorUsedError;
  List<Activity> get activities => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WeeklyActivityCopyWith<WeeklyActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyActivityCopyWith<$Res> {
  factory $WeeklyActivityCopyWith(
          WeeklyActivity value, $Res Function(WeeklyActivity) then) =
      _$WeeklyActivityCopyWithImpl<$Res, WeeklyActivity>;
  @useResult
  $Res call(
      {WeeklyActivityId id,
      @UserIdConverter() UserId userId,
      List<Activity> activities,
      int count});
}

/// @nodoc
class _$WeeklyActivityCopyWithImpl<$Res, $Val extends WeeklyActivity>
    implements $WeeklyActivityCopyWith<$Res> {
  _$WeeklyActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? activities = null,
    Object? count = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as WeeklyActivityId,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as UserId,
      activities: null == activities
          ? _value.activities
          : activities // ignore: cast_nullable_to_non_nullable
              as List<Activity>,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeeklyActivityImplCopyWith<$Res>
    implements $WeeklyActivityCopyWith<$Res> {
  factory _$$WeeklyActivityImplCopyWith(_$WeeklyActivityImpl value,
          $Res Function(_$WeeklyActivityImpl) then) =
      __$$WeeklyActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {WeeklyActivityId id,
      @UserIdConverter() UserId userId,
      List<Activity> activities,
      int count});
}

/// @nodoc
class __$$WeeklyActivityImplCopyWithImpl<$Res>
    extends _$WeeklyActivityCopyWithImpl<$Res, _$WeeklyActivityImpl>
    implements _$$WeeklyActivityImplCopyWith<$Res> {
  __$$WeeklyActivityImplCopyWithImpl(
      _$WeeklyActivityImpl _value, $Res Function(_$WeeklyActivityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? activities = null,
    Object? count = null,
  }) {
    return _then(_$WeeklyActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as WeeklyActivityId,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as UserId,
      activities: null == activities
          ? _value._activities
          : activities // ignore: cast_nullable_to_non_nullable
              as List<Activity>,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$WeeklyActivityImpl extends _WeeklyActivity {
  const _$WeeklyActivityImpl(
      {required this.id,
      @UserIdConverter() required this.userId,
      required final List<Activity> activities,
      required this.count})
      : _activities = activities,
        super._();

  factory _$WeeklyActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyActivityImplFromJson(json);

  @override
  final WeeklyActivityId id;
  @override
  @UserIdConverter()
  final UserId userId;
  final List<Activity> _activities;
  @override
  List<Activity> get activities {
    if (_activities is EqualUnmodifiableListView) return _activities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activities);
  }

  @override
  final int count;

  @override
  String toString() {
    return 'WeeklyActivity(id: $id, userId: $userId, activities: $activities, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality()
                .equals(other._activities, _activities) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId,
      const DeepCollectionEquality().hash(_activities), count);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyActivityImplCopyWith<_$WeeklyActivityImpl> get copyWith =>
      __$$WeeklyActivityImplCopyWithImpl<_$WeeklyActivityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyActivityImplToJson(
      this,
    );
  }
}

abstract class _WeeklyActivity extends WeeklyActivity {
  const factory _WeeklyActivity(
      {required final WeeklyActivityId id,
      @UserIdConverter() required final UserId userId,
      required final List<Activity> activities,
      required final int count}) = _$WeeklyActivityImpl;
  const _WeeklyActivity._() : super._();

  factory _WeeklyActivity.fromJson(Map<String, dynamic> json) =
      _$WeeklyActivityImpl.fromJson;

  @override
  WeeklyActivityId get id;
  @override
  @UserIdConverter()
  UserId get userId;
  @override
  List<Activity> get activities;
  @override
  int get count;
  @override
  @JsonKey(ignore: true)
  _$$WeeklyActivityImplCopyWith<_$WeeklyActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

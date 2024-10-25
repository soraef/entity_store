// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SubTask _$SubTaskFromJson(Map<String, dynamic> json) {
  return _SubTask.fromJson(json);
}

/// @nodoc
mixin _$SubTask {
  SubTaskId get id => throw _privateConstructorUsedError;
  @TaskIdConverter()
  TaskId get taskId => throw _privateConstructorUsedError;
  @UserIdConverter()
  UserId get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get done => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SubTaskCopyWith<SubTask> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubTaskCopyWith<$Res> {
  factory $SubTaskCopyWith(SubTask value, $Res Function(SubTask) then) =
      _$SubTaskCopyWithImpl<$Res, SubTask>;
  @useResult
  $Res call(
      {SubTaskId id,
      @TaskIdConverter() TaskId taskId,
      @UserIdConverter() UserId userId,
      String name,
      bool done,
      @DateTimeConverter() DateTime createdAt,
      @DateTimeConverter() DateTime updatedAt});
}

/// @nodoc
class _$SubTaskCopyWithImpl<$Res, $Val extends SubTask>
    implements $SubTaskCopyWith<$Res> {
  _$SubTaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? userId = null,
    Object? name = null,
    Object? done = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as SubTaskId,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as TaskId,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as UserId,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      done: null == done
          ? _value.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubTaskImplCopyWith<$Res> implements $SubTaskCopyWith<$Res> {
  factory _$$SubTaskImplCopyWith(
          _$SubTaskImpl value, $Res Function(_$SubTaskImpl) then) =
      __$$SubTaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SubTaskId id,
      @TaskIdConverter() TaskId taskId,
      @UserIdConverter() UserId userId,
      String name,
      bool done,
      @DateTimeConverter() DateTime createdAt,
      @DateTimeConverter() DateTime updatedAt});
}

/// @nodoc
class __$$SubTaskImplCopyWithImpl<$Res>
    extends _$SubTaskCopyWithImpl<$Res, _$SubTaskImpl>
    implements _$$SubTaskImplCopyWith<$Res> {
  __$$SubTaskImplCopyWithImpl(
      _$SubTaskImpl _value, $Res Function(_$SubTaskImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? userId = null,
    Object? name = null,
    Object? done = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$SubTaskImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as SubTaskId,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as TaskId,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as UserId,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      done: null == done
          ? _value.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$SubTaskImpl extends _SubTask {
  const _$SubTaskImpl(
      {required this.id,
      @TaskIdConverter() required this.taskId,
      @UserIdConverter() required this.userId,
      required this.name,
      required this.done,
      @DateTimeConverter() required this.createdAt,
      @DateTimeConverter() required this.updatedAt})
      : super._();

  factory _$SubTaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubTaskImplFromJson(json);

  @override
  final SubTaskId id;
  @override
  @TaskIdConverter()
  final TaskId taskId;
  @override
  @UserIdConverter()
  final UserId userId;
  @override
  final String name;
  @override
  final bool done;
  @override
  @DateTimeConverter()
  final DateTime createdAt;
  @override
  @DateTimeConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SubTask(id: $id, taskId: $taskId, userId: $userId, name: $name, done: $done, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubTaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.done, done) || other.done == done) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, taskId, userId, name, done, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubTaskImplCopyWith<_$SubTaskImpl> get copyWith =>
      __$$SubTaskImplCopyWithImpl<_$SubTaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubTaskImplToJson(
      this,
    );
  }
}

abstract class _SubTask extends SubTask {
  const factory _SubTask(
      {required final SubTaskId id,
      @TaskIdConverter() required final TaskId taskId,
      @UserIdConverter() required final UserId userId,
      required final String name,
      required final bool done,
      @DateTimeConverter() required final DateTime createdAt,
      @DateTimeConverter() required final DateTime updatedAt}) = _$SubTaskImpl;
  const _SubTask._() : super._();

  factory _SubTask.fromJson(Map<String, dynamic> json) = _$SubTaskImpl.fromJson;

  @override
  SubTaskId get id;
  @override
  @TaskIdConverter()
  TaskId get taskId;
  @override
  @UserIdConverter()
  UserId get userId;
  @override
  String get name;
  @override
  bool get done;
  @override
  @DateTimeConverter()
  DateTime get createdAt;
  @override
  @DateTimeConverter()
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$SubTaskImplCopyWith<_$SubTaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

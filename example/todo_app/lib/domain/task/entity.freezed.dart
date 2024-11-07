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

Task _$TaskFromJson(Map<String, dynamic> json) {
  return _Task.fromJson(json);
}

/// @nodoc
mixin _$Task {
  @TaskIdConverter()
  TaskId get id => throw _privateConstructorUsedError;
  @UserIdConverter()
  UserId get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get done => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: <SubTask>[])
  List<SubTask> get subTasks => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TaskCopyWith<Task> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskCopyWith<$Res> {
  factory $TaskCopyWith(Task value, $Res Function(Task) then) =
      _$TaskCopyWithImpl<$Res, Task>;
  @useResult
  $Res call(
      {@TaskIdConverter() TaskId id,
      @UserIdConverter() UserId userId,
      String name,
      bool done,
      @JsonKey(defaultValue: <SubTask>[]) List<SubTask> subTasks,
      @DateTimeConverter() DateTime createdAt,
      @DateTimeConverter() DateTime updatedAt});
}

/// @nodoc
class _$TaskCopyWithImpl<$Res, $Val extends Task>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? done = null,
    Object? subTasks = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
      subTasks: null == subTasks
          ? _value.subTasks
          : subTasks // ignore: cast_nullable_to_non_nullable
              as List<SubTask>,
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
abstract class _$$TaskImplCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$$TaskImplCopyWith(
          _$TaskImpl value, $Res Function(_$TaskImpl) then) =
      __$$TaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@TaskIdConverter() TaskId id,
      @UserIdConverter() UserId userId,
      String name,
      bool done,
      @JsonKey(defaultValue: <SubTask>[]) List<SubTask> subTasks,
      @DateTimeConverter() DateTime createdAt,
      @DateTimeConverter() DateTime updatedAt});
}

/// @nodoc
class __$$TaskImplCopyWithImpl<$Res>
    extends _$TaskCopyWithImpl<$Res, _$TaskImpl>
    implements _$$TaskImplCopyWith<$Res> {
  __$$TaskImplCopyWithImpl(_$TaskImpl _value, $Res Function(_$TaskImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? done = null,
    Object? subTasks = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$TaskImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
      subTasks: null == subTasks
          ? _value._subTasks
          : subTasks // ignore: cast_nullable_to_non_nullable
              as List<SubTask>,
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
class _$TaskImpl extends _Task {
  const _$TaskImpl(
      {@TaskIdConverter() required this.id,
      @UserIdConverter() required this.userId,
      required this.name,
      required this.done,
      @JsonKey(defaultValue: <SubTask>[]) required final List<SubTask> subTasks,
      @DateTimeConverter() required this.createdAt,
      @DateTimeConverter() required this.updatedAt})
      : _subTasks = subTasks,
        super._();

  factory _$TaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskImplFromJson(json);

  @override
  @TaskIdConverter()
  final TaskId id;
  @override
  @UserIdConverter()
  final UserId userId;
  @override
  final String name;
  @override
  final bool done;
  final List<SubTask> _subTasks;
  @override
  @JsonKey(defaultValue: <SubTask>[])
  List<SubTask> get subTasks {
    if (_subTasks is EqualUnmodifiableListView) return _subTasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subTasks);
  }

  @override
  @DateTimeConverter()
  final DateTime createdAt;
  @override
  @DateTimeConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Task(id: $id, userId: $userId, name: $name, done: $done, subTasks: $subTasks, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.done, done) || other.done == done) &&
            const DeepCollectionEquality().equals(other._subTasks, _subTasks) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, name, done,
      const DeepCollectionEquality().hash(_subTasks), createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      __$$TaskImplCopyWithImpl<_$TaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskImplToJson(
      this,
    );
  }
}

abstract class _Task extends Task {
  const factory _Task(
      {@TaskIdConverter() required final TaskId id,
      @UserIdConverter() required final UserId userId,
      required final String name,
      required final bool done,
      @JsonKey(defaultValue: <SubTask>[]) required final List<SubTask> subTasks,
      @DateTimeConverter() required final DateTime createdAt,
      @DateTimeConverter() required final DateTime updatedAt}) = _$TaskImpl;
  const _Task._() : super._();

  factory _Task.fromJson(Map<String, dynamic> json) = _$TaskImpl.fromJson;

  @override
  @TaskIdConverter()
  TaskId get id;
  @override
  @UserIdConverter()
  UserId get userId;
  @override
  String get name;
  @override
  bool get done;
  @override
  @JsonKey(defaultValue: <SubTask>[])
  List<SubTask> get subTasks;
  @override
  @DateTimeConverter()
  DateTime get createdAt;
  @override
  @DateTimeConverter()
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// ignore_for_file: invalid_annotation_target

import 'package:entity_store/entity_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'id.dart';

part 'entity.freezed.dart';
part 'entity.g.dart';

@freezed
class User with _$User implements Entity {
  const User._();
  @JsonSerializable(explicitToJson: true)
  const factory User({
    required UserId id,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

import 'package:entity_store/entity_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

extension type UserId(String value) implements String {
  factory UserId.create() {
    return UserId(const Uuid().v4());
  }
}

class UserIdConverter implements JsonConverter<UserId, String> {
  const UserIdConverter();
  @override
  UserId fromJson(String json) {
    return UserId(json);
  }

  @override
  String toJson(UserId object) {
    return object.value;
  }
}

class UserIdListConverter
    implements JsonConverter<List<UserId>, List<dynamic>> {
  const UserIdListConverter();

  @override
  List<UserId> fromJson(List<dynamic> json) {
    return json.map((e) => UserId(e)).toList();
  }

  @override
  List<String> toJson(List<UserId> object) {
    return object.map((e) => e.value).toList();
  }
}

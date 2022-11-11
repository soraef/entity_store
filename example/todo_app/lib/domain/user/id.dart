import 'package:entity_store/entity_store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class UserId extends Id {
  const UserId(String value) : super(value);
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

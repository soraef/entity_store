import 'package:entity_store/entity_store.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:todo_app/domain/user/id.dart';

class Auth extends Entity {
  @override
  final AuthId id = AuthId("authId");
  final UserId? userId;

  Auth(this.userId);

  factory Auth.init() {
    return Auth(null);
  }

  factory Auth.login(UserId userId) {
    return Auth(userId);
  }

  bool get isLogin => userId != null;

  Map<String, dynamic> toJson() {
    return {
      "userId": userId?.value,
    };
  }
}

extension type AuthId(String value) implements String {
  AuthId get id => AuthId(this);
}

class AuthIdJsonConverter extends JsonConverter<AuthId, String> {
  const AuthIdJsonConverter();

  @override
  AuthId fromJson(String json) {
    return AuthId(json);
  }

  @override
  String toJson(AuthId object) {
    return object.value;
  }
}

import 'package:entity_store/entity_store.dart';
import 'package:todo_app/domain/user/id.dart';

class Auth extends SingletonEntity {
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

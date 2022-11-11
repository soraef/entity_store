import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/domain/user/id.dart';
import 'package:todo_app/infrastracture/store/riverpod_store.dart';

class Authentication {
  final UserId? userId;

  Authentication(this.userId);

  factory Authentication.init() {
    return Authentication(null);
  }

  factory Authentication.login(UserId userId) {
    return Authentication(userId);
  }

  bool get isLogin => userId != null;
}

final authStore = StateNotifierProvider<AuthStore, Authentication>(
  (ref) => AuthStore(),
);

class AuthStore extends RiverpodStore<Authentication> {
  AuthStore() : super(Authentication.init());
}
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/application/store/session_store/auth_store.dart';
import 'package:todo_app/domain/user/id.dart';

final authUsecase = Provider(
  (ref) => AuthUsecase(ref.read(authStore.notifier)),
);

class AuthUsecase {
  final AuthStore authStore;

  AuthUsecase(this.authStore);

  void login() {
    authStore.update(
      (prev) => Authentication.login(const UserId("user1")),
    );
  }
}

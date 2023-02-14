import 'package:entity_store/entity_store.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/application/store/session_store/auth_store.dart';
import 'package:todo_app/domain/auth/entity.dart';
import 'package:todo_app/domain/auth/repository.dart';
import 'package:todo_app/domain/user/id.dart';

final authUsecase = Provider(
  (ref) => AuthUsecase(ref.read(authRepo)),
);

class AuthUsecase {
  final AuthRepo repo;

  AuthUsecase(this.repo);

  void login() {
    repo.save(Auth.login(const UserId("user1")));
  }

  void logout() {
    repo.save(Auth.init());
  }
}

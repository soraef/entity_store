import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/domain/auth/entity.dart';
import 'package:todo_app/domain/auth/repository.dart';
import 'package:todo_app/domain/user/entity.dart';
import 'package:todo_app/domain/user/id.dart';
import 'package:todo_app/domain/user/repository.dart';

final authUsecase = Provider(
  (ref) => AuthUsecase(
    ref.read(authRepo),
    ref.read(userRepo),
  ),
);

class AuthUsecase {
  final AuthRepo authRepo;
  final UserRepository userRepo;

  AuthUsecase(
    this.authRepo,
    this.userRepo,
  );

  Future<void> login() async {
    final userId = UserId("user1");
    final user = await userRepo.findById(userId);
    if (user.isOk && user.ok == null) {
      await userRepo.save(User(id: userId));
    }
    await authRepo.save(Auth.login(UserId("user1")));
  }

  Future<void> logout() async {
    await authRepo.save(Auth.init());
  }
}

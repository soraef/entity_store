import 'package:entity_store/entity_store.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/domain/auth/entity.dart';
import 'package:todo_app/domain/user/entity.dart';
import 'package:todo_app/domain/user/id.dart';
import 'package:todo_app/infrastracture/repository/repository.dart';

final authUsecase = Provider(
  (ref) => AuthUsecase(
    ref.read(repoInMemoryFactory).getRepo(),
    ref.read(repoRemoteFactory).getRepo(),
  ),
);

class AuthUsecase {
  final IRepo<CommonId, Auth> authRepo;
  final IRepo<UserId, User> userRepo;

  AuthUsecase(
    this.authRepo,
    this.userRepo,
  );

  Future<void> login() async {
    const userId = UserId("user1");
    final user = await userRepo.get(userId);
    if (user.isOk && user.ok == null) {
      await userRepo.save(const User(id: userId));
    }
    await authRepo.save(Auth.login(const UserId("user1")));
  }

  Future<void> logout() async {
    await authRepo.save(Auth.init());
  }
}

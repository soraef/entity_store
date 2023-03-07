import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skyreach_result/skyreach_result.dart';
import 'package:todo_app/domain/auth/entity.dart';
import 'package:todo_app/domain/auth/repository.dart';
import 'package:todo_app/domain/todo/entity.dart';
import 'package:todo_app/domain/todo/id.dart';
import 'package:todo_app/domain/todo/repository.dart';
import 'package:todo_app/domain/user/entity.dart';
import 'package:todo_app/domain/user/id.dart';
import 'package:todo_app/domain/user/repository.dart';
import 'package:todo_app/infrastracture/dispatcher/dispatcher.dart';

final todoUsecase = Provider(
  (ref) => TodoUsecase(
    ref.watch(
      entityStore.select(
        (value) => value.get<CommonId, Auth>(CommonId.singleton())?.userId,
      ),
    ),
    ref.read(userRepo),
    ref.read(authRepo),
  ),
);

class TodoUsecase {
  final UserId? userId;
  final UserRepository userRepository;
  final AuthRepo authRepo;

  TodoUsecase(this.userId, this.userRepository, this.authRepo);

  TodoRepository _todoRepo(UserId userId) {
    return userRepository.getRepo(userId);
  }

  Future<void> create(String name) async {
    final newTodo = Todo.create(
      name: name,
      userId: userId!,
    );

    await _todoRepo(userId!).save(newTodo);
  }

  Future<Result<Todo, Exception>> check(TodoId id, bool done) async {
    final todo = await _todoRepo(userId!).findById(
      id,
      // options: const GetOptions(useCache: true),
    );
    if (todo.isOk && todo.ok != null) {
      return await _todoRepo(userId!).save(todo.ok!.copyWith(done: done));
    }

    return Result.err(Exception("Todo Not Found"));
  }

  Future<void> delete(Todo todo) async {
    await _todoRepo(userId!).delete(todo.id);
  }

  Future<void> loadUserAll() async {
    final auth = (await authRepo.findById(CommonId.singleton())).ok;
    assert(auth?.isLogin == true);
    await _todoRepo(userId!)
        .query()
        .where("userId", isEqualTo: auth!.userId!.value)
        .findAll();
  }
}

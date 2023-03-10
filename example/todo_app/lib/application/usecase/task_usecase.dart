import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skyreach_result/skyreach_result.dart';
import 'package:todo_app/domain/auth/entity.dart';
import 'package:todo_app/domain/auth/repository.dart';
import 'package:todo_app/domain/sub_task/entity.dart';
import 'package:todo_app/domain/sub_task/id.dart';
import 'package:todo_app/domain/sub_task/repository.dart';
import 'package:todo_app/domain/task/entity.dart';
import 'package:todo_app/domain/task/id.dart';
import 'package:todo_app/domain/task/repository.dart';
import 'package:todo_app/domain/user/entity.dart';
import 'package:todo_app/domain/user/id.dart';
import 'package:todo_app/domain/user/repository.dart';
import 'package:todo_app/infrastracture/dispatcher/dispatcher.dart';

final taskUsecase = Provider(
  (ref) => TaskUsecase(
    ref.watch(
      entityStore.select(
        (value) => value.get<CommonId, Auth>(CommonId.singleton())?.userId,
      ),
    ),
    ref.read(userRepo),
    ref.read(authRepo),
  ),
);

class TaskUsecase {
  final UserId? userId;
  final UserRepository userRepository;
  final AuthRepo authRepo;

  TaskUsecase(this.userId, this.userRepository, this.authRepo);

  TaskRepository _taskRepo(UserId userId) {
    return userRepository.getRepository(userId);
  }

  SubTaskRepository _subTaskRepo(UserId userId) {
    return userRepository.getRepository(userId);
  }

  Future<void> create(String name) async {
    final newTask = Task.create(
      name: name,
      userId: userId!,
    );

    await _taskRepo(userId!).save(newTask);
  }

  Future<Result<Task, Exception>> check(TaskId id, bool done) async {
    final task = await _taskRepo(userId!).findById(id);
    if (task.isOk && task.ok != null) {
      return await _taskRepo(userId!).save(task.ok!.copyWith(done: done));
    }

    return Result.err(Exception("Task Not Found"));
  }

  Future<void> delete(Task task) async {
    await _taskRepo(userId!).delete(task.id);
  }

  Future<void> loadUserAll() async {
    final auth = (await authRepo.findById(CommonId.singleton())).ok;
    assert(auth?.isLogin == true);
    await _taskRepo(userId!)
        .query()
        .where("userId", isEqualTo: auth!.userId!.value)
        .findAll();
  }

  Future<void> createSubTask(TaskId taskId, String name) async {
    final newTask = SubTask.create(
      taskId: taskId,
      name: name,
      userId: userId!,
    );

    await _subTaskRepo(userId!).save(newTask);
  }

  Future<Result<SubTask, Exception>> checkSubTask(
    SubTaskId subTaskId,
    bool done,
  ) async {
    final task = await _subTaskRepo(userId!).findById(
      subTaskId,
    );
    if (task.isOk && task.ok != null) {
      return await _subTaskRepo(userId!).save(task.ok!.copyWith(done: done));
    }

    return Result.err(Exception("Task Not Found"));
  }

  Future<void> deleteSubTask(SubTask task) async {
    await _subTaskRepo(userId!).delete(task.id);
  }

  Future<void> loadAllSubTask(Task task) async {
    final auth = (await authRepo.findById(CommonId.singleton())).ok;
    assert(auth?.isLogin == true);

    await _subTaskRepo(userId!)
        .query()
        .where("taskId", isEqualTo: task.id.value)
        .findAll();
  }
}

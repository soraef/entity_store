import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:todo_app/domain/auth/entity.dart';
import 'package:todo_app/domain/auth/repository.dart';
import 'package:todo_app/domain/sub_task/entity.dart';
import 'package:todo_app/domain/sub_task/id.dart';
import 'package:todo_app/domain/task/entity.dart';
import 'package:todo_app/domain/task/id.dart';
import 'package:todo_app/domain/task/repository.dart';
import 'package:todo_app/domain/user/id.dart';
import 'package:todo_app/domain/user/repository.dart';
import 'package:todo_app/domain/weekly_activity/repository.dart';
import 'package:todo_app/domain/weekly_activity/weekly_activity.dart';
import 'package:todo_app/infrastracture/dispatcher/dispatcher.dart';
import 'package:type_result/type_result.dart';

final taskUsecase = Provider(
  (ref) => TaskUsecase(
    ref.read(entityStore).value.get<AuthId, Auth>(AuthId("authId"))?.userId!,
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

  WeeklyActivityRepository _activityRepository(UserId userId) {
    return userRepository.getRepository(userId);
  }

  Future<void> create(String name) async {
    final newTask = Task.create(
      name: name,
      userId: userId!,
    );

    await _taskRepo(userId!).save(newTask);

    _activityRepository(userId!).upsert(
      WeeklyActivityId.create(userId!, DateTime.now()),
      creater: () => WeeklyActivity.createNow(
        userId: userId!,
        activities: [],
      ),
      updater: (prev) => prev.addActivity("Create Task: $name"),
    );
  }

  Future<Result<Task, Exception>> check(TaskId id, bool done) async {
    final result = await _taskRepo(userId!).upsert(
      id,
      creater: () => null,
      updater: (prev) => done ? prev.complete() : prev.uncomplete(),
      options: FirestoreCreateOrUpdateOptions(
        useTransaction: false,
      ),
    );

    if (result.isOk && result.ok != null) {
      return Result.ok(result.ok!);
    }

    _activityRepository(userId!).upsert(
      WeeklyActivityId.create(userId!, DateTime.now()),
      creater: () => WeeklyActivity.createNow(
        userId: userId!,
        activities: [],
      ),
      updater: (prev) {
        if (done) {
          return prev.addActivity("Complete Task: ${id.value}");
        } else {
          return prev.addActivity("Uncomplete Task: ${id.value}");
        }
      },
    );

    return Result.err(Exception("Task Not Found"));
  }

  Future<void> delete(Task task) async {
    _activityRepository(userId!).upsert(
      WeeklyActivityId.create(userId!, DateTime.now()),
      creater: () => WeeklyActivity.createNow(
        userId: userId!,
        activities: [],
      ),
      updater: (prev) => prev.addActivity("Delete Task: ${task.name}"),
    );

    await _taskRepo(userId!).delete(task.id);
  }

  Future<void> loadUserAll() async {
    final auth = (await authRepo.findById(AuthId("authId"))).ok;
    assert(auth?.isLogin == true);
    await _taskRepo(userId!)
        .query()
        .where("userId", isEqualTo: auth!.userId!.value)
        .findAll();
  }

  Future<void> createSubTask(TaskId taskId, String name) async {
    _activityRepository(userId!).upsert(
      WeeklyActivityId.create(userId!, DateTime.now()),
      creater: () => WeeklyActivity.createNow(
        userId: userId!,
        activities: [],
      ),
      updater: (prev) => prev.addActivity("Create SubTask: $name"),
    );
    await _taskRepo(userId!).upsert(
      taskId,
      creater: () => null,
      updater: (prev) => prev.addSubTask(name),
    );
  }

  Future<Result<SubTask, Exception>> checkSubTask(
    TaskId taskId,
    SubTaskId subTaskId,
    bool done,
  ) async {
    final result = await _taskRepo(userId!).upsert(
      taskId,
      creater: () => null,
      updater: (prev) => done
          ? prev.completeSubTask(subTaskId)
          : prev.uncompleteSubTask(subTaskId),
    );

    _activityRepository(userId!).upsert(
      WeeklyActivityId.create(userId!, DateTime.now()),
      creater: () => WeeklyActivity.createNow(
        userId: userId!,
        activities: [],
      ),
      updater: (prev) {
        if (done) {
          return prev.addActivity("Complete SubTask: ${subTaskId.value}");
        } else {
          return prev.addActivity("Uncomplete SubTask: ${subTaskId.value}");
        }
      },
    );

    if (result.isOk && result.ok != null) {
      final sub = result.ok!.findSubTaskById(subTaskId);
      if (sub != null) {
        return Result.ok(sub);
      }
    }

    return Result.err(Exception("Task Not Found"));
  }

  Future<void> deleteSubTask(TaskId taskId, SubTask task) async {
    _activityRepository(userId!).upsert(
      WeeklyActivityId.create(userId!, DateTime.now()),
      creater: () => WeeklyActivity.createNow(
        userId: userId!,
        activities: [],
      ),
      updater: (prev) => prev.addActivity("Delete Task: ${task.name}"),
    );

    await _taskRepo(userId!).upsert(
      taskId,
      creater: () => null,
      updater: (prev) => prev.removeSubTask(task.id),
    );
  }
}

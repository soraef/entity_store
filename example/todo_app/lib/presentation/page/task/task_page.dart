import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:entity_store/entity_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/application/usecase/task_usecase.dart';
import 'package:todo_app/domain/auth/entity.dart';
import 'package:todo_app/domain/sub_task/entity.dart';
import 'package:todo_app/domain/sub_task/id.dart';
import 'package:todo_app/domain/task/entity.dart';
import 'package:todo_app/domain/task/id.dart';
import 'package:todo_app/infrastracture/dispatcher/dispatcher.dart';

class TaskPage extends HookConsumerWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(
      entityStore.select((value) => value.where<TaskId, Task>()),
    );

    final userId = ref
        .watch(entityStore.select(
          (value) => value.where<CommonId, Auth>().atOrNull(0),
        ))
        ?.userId;

    if (userId == null) {
      return Container();
    }

    // final loading = ref.read(taskInfiniteLoading(userId).notifier);

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          ref.read(taskUsecase).loadUserAll();
        });
        return null;
      },
      const [],
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                TextButton(
                  child: const Text("Create Task"),
                  onPressed: () async {
                    final texts = await showTextInputDialog(
                      context: context,
                      textFields: [const DialogTextField()],
                    );

                    if (texts?.isNotEmpty == true) {
                      final text = texts!.first;
                      await ref.read(taskUsecase).create(text);
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.entities.length,
                itemBuilder: (context, index) {
                  final task = tasks.toList().elementAt(index);
                  return CheckboxListTile(
                    title: Text(task.name),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (bool? value) {
                      if (value != null) {
                        ref.read(taskUsecase).check(task.id, value);
                      }
                    },
                    secondary: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return SubTaskListPage(task: task);
                            },
                          ),
                        );
                      },
                      child: const Text(
                        "detail",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    value: task.done,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SubTaskListPage extends ConsumerWidget {
  final Task task;
  const SubTaskListPage({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subTasks = ref.watch(entityStore.select((value) =>
        value.where<SubTaskId, SubTask>((e) => e.taskId == task.id)));

    return Scaffold(
      appBar: AppBar(
        title: Text(task.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                TextButton(
                  child: const Text("Create Task"),
                  onPressed: () async {
                    final texts = await showTextInputDialog(
                      context: context,
                      textFields: [const DialogTextField()],
                    );

                    if (texts?.isNotEmpty == true) {
                      final text = texts!.first;
                      await ref.read(taskUsecase).createSubTask(task.id, text);
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: subTasks.entities.length,
                itemBuilder: (context, index) {
                  final task = subTasks.toList().elementAt(index);
                  return CheckboxListTile(
                    title: Text(task.name),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (bool? value) {
                      if (value != null) {
                        ref.read(taskUsecase).checkSubTask(task.id, value);
                      }
                    },
                    secondary: TextButton(
                      onPressed: () {
                        ref.read(taskUsecase).deleteSubTask(task);
                      },
                      child: const Text(
                        "delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    value: task.done,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// // final taskInfiniteLoading =
// //     StateNotifierProvider.family<TaskInfiniteLoading, LoadingState, UserId>(
// //         (ref, userId) => TaskInfiniteLoading(ref, userId));

// // class TaskInfiniteLoading extends InfiniteLoadingNotifier<TaskId, Task> {
// //   final Ref ref;
// //   final UserId userId;

// //   TaskInfiniteLoading(this.ref, this.userId);

// //   @override
// //   IRepository<TaskId, Task> get repo => ref.read(repoRemoteFactory).getRepo();

// //   @override
// //   Future<void> load({int limit = 10}) async {
// //     await cursor((q) => q.limit(limit));
// //   }
// // }

// // class EntityListView<Id, E extends Entity<Id>> extends StatelessWidget {
// //   const EntityListView({
// //     super.key,
// //     required this.loading,
// //     required this.entities,
// //     required this.itemBuilder,
// //   });

// //   final InfiniteLoadingNotifier<Id, E> loading;
// //   final List<E> entities;
// //   final Widget Function(E entity) itemBuilder;

// //   @override
// //   Widget build(BuildContext context) {
// //     return ListView.builder(
// //       itemCount: entities.length,
// //       itemBuilder: (context, index) {
// //         if (index + 1 == entities.length) {
// //           WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
// //             loading.load();
// //           });
// //         }

// //         return itemBuilder(entities[index]);
// //       },
// //     );
// //   }
// // }

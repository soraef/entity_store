import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:entity_store/entity_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/application/usecase/todo_usecase.dart';
import 'package:todo_app/domain/auth/entity.dart';
import 'package:todo_app/domain/todo/entity.dart';
import 'package:todo_app/domain/todo/id.dart';
import 'package:todo_app/infrastracture/dispatcher/dispatcher.dart';

class TodoPage extends HookConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(
      entityStore.select((value) => value.where<TodoId, Todo>()),
    );

    final userId = ref
        .watch(entityStore.select(
          (value) => value.where<CommonId, Auth>().atOrNull(0),
        ))
        ?.userId;

    if (userId == null) {
      return Container();
    }

    // final loading = ref.read(todoInfiniteLoading(userId).notifier);

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          ref.read(todoUsecase).loadUserAll();
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
                  child: const Text("Create Todo"),
                  onPressed: () async {
                    final texts = await showTextInputDialog(
                      context: context,
                      textFields: [const DialogTextField()],
                    );

                    if (texts?.isNotEmpty == true) {
                      final text = texts!.first;
                      await ref.read(todoUsecase).create(text);
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: todos.entities.length,
                itemBuilder: (context, index) {
                  final todo = todos.toList().elementAt(index);
                  return CheckboxListTile(
                    title: Text(todo.name),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (bool? value) {
                      if (value != null) {
                        ref.read(todoUsecase).check(todo.id, value);
                      }
                    },
                    secondary: TextButton(
                      onPressed: () {
                        ref.read(todoUsecase).delete(todo);
                      },
                      child: const Text(
                        "delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    value: todo.done,
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

// final todoInfiniteLoading =
//     StateNotifierProvider.family<TodoInfiniteLoading, LoadingState, UserId>(
//         (ref, userId) => TodoInfiniteLoading(ref, userId));

// class TodoInfiniteLoading extends InfiniteLoadingNotifier<TodoId, Todo> {
//   final Ref ref;
//   final UserId userId;

//   TodoInfiniteLoading(this.ref, this.userId);

//   @override
//   IRepository<TodoId, Todo> get repo => ref.read(repoRemoteFactory).getRepo();

//   @override
//   Future<void> load({int limit = 10}) async {
//     await cursor((q) => q.limit(limit));
//   }
// }

// class EntityListView<Id, E extends Entity<Id>> extends StatelessWidget {
//   const EntityListView({
//     super.key,
//     required this.loading,
//     required this.entities,
//     required this.itemBuilder,
//   });

//   final InfiniteLoadingNotifier<Id, E> loading;
//   final List<E> entities;
//   final Widget Function(E entity) itemBuilder;

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: entities.length,
//       itemBuilder: (context, index) {
//         if (index + 1 == entities.length) {
//           WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//             loading.load();
//           });
//         }

//         return itemBuilder(entities[index]);
//       },
//     );
//   }
// }

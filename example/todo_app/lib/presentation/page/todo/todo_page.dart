import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/application/store/entity_store/todo_store.dart';
import 'package:todo_app/application/usecase/todo_usecase.dart';
import 'package:todo_app/domain/todo/entity.dart';
import 'package:todo_app/domain/todo/id.dart';

class TodoPage extends HookConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoStore);

    useEffect(
      () {
        ref.read(todoUsecase).loadMore();
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
              child: EntityListView<TodoId, Todo>(
                entities: todos.entities.toList(),
                pagination: ref.read(todoUsecase),
                itemBuilder: (todo) {
                  // final todo = todos.toList().elementAt(index);
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

class EntityListView<Id, E extends Entity<Id>> extends StatelessWidget {
  const EntityListView({
    super.key,
    required this.pagination,
    required this.entities,
    required this.itemBuilder,
  });

  final PaginationMixIn pagination;
  final List<E> entities;
  final Widget Function(E entity) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entities.length,
      itemBuilder: (context, index) {
        if (index + 1 == entities.length && pagination.hasMore) {
          pagination.loadMore();
        }

        return itemBuilder(entities[index]);
      },
    );
  }
}

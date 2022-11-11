import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/application/store/entity_store/todo_store.dart';
import 'package:todo_app/application/usecase/todo_usecase.dart';

class TodoPage extends HookConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoStore);

    useEffect(
      () {
        ref.read(todoUsecase).load();
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
                      textFields: [DialogTextField()],
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
                itemBuilder: (BuildContext context, int index) {
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
                itemCount: todos.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}

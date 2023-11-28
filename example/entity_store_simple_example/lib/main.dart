import 'package:entity_store/entity_store.dart';
import 'package:flutter/material.dart';

import 'models/todo.dart';

final entityStoreNotifier = EntityStoreNotifier();
final entityStoreController = EntityStoreController(entityStoreNotifier);
final storageHandler = InMemoryStorageHandler();
final todoRepository = TodoRepository(entityStoreController, storageHandler);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EntityStoreProviderScope(
      entityStoreNotifier: entityStoreNotifier,
      child: MaterialApp(
        title: 'Entity Store Simple Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Simple Todo Example'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _id = 0;

  void _addTodo() {
    _id++;
    todoRepository.save(Todo.create(_id));
  }

  @override
  Widget build(BuildContext context) {
    final todoIds = context.selectAll<int, Todo, List<int>>(
      (value) => value.ids.toList(),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          for (final todoId in todoIds)
            TodoTile(
              todoId: todoId,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodoTile extends StatelessWidget {
  final int todoId;
  const TodoTile({
    super.key,
    required this.todoId,
  });

  @override
  Widget build(BuildContext context) {
    final todo = context.watchOne<int, Todo>(todoId);
    if (todo == null) {
      return const SizedBox();
    }

    return CheckboxListTile(
      title: Text(todo.name),
      value: todo.isDone,
      onChanged: (bool? value) {
        if (value == null) {
          return;
        }
        todoRepository.save(todo.toggle());
      },
    );
  }
}

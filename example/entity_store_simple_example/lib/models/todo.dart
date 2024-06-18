import 'package:entity_store/entity_store.dart';
import 'dart:math';

String getRandomTodoName() {
  final random = Random();
  const todoNames = [
    "Conquer the Laundry Mountain",
    "Tame the Wild Email Inbox",
    "Embark on the Epic Dishwashing Quest",
    "Navigate the Grocery Store Jungle",
    "Master the Art of Sock Pairing"
  ];

  return todoNames[random.nextInt(todoNames.length)];
}

class Todo implements Entity<int> {
  @override
  final int id;
  final String name;
  final bool isDone;

  Todo({
    required this.id,
    required this.name,
    required this.isDone,
  });

  factory Todo.create(int id) {
    return Todo(
      id: id,
      name: getRandomTodoName(),
      isDone: false,
    );
  }

  Todo toggle() {
    return Todo(
      id: id,
      name: name,
      isDone: isDone ? false : true,
    );
  }
}

class SubTodo implements Entity<int> {
  @override
  final int id;
  final int todoId;
  final String name;
  final bool isDone;

  SubTodo({
    required this.id,
    required this.name,
    required this.isDone,
    required this.todoId,
  });

  factory SubTodo.create(int id, int todoId) {
    return SubTodo(
      id: id,
      todoId: todoId,
      name: getRandomTodoName(),
      isDone: false,
    );
  }

  SubTodo toggle() {
    return SubTodo(
      id: id,
      todoId: todoId,
      name: name,
      isDone: isDone ? false : true,
    );
  }
}

class TodoRepository extends LocalStorageRepository<int, Todo> {
  TodoRepository(super.controller, super.localStorageHandler);

  @override
  Todo fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json["id"],
      name: json["name"],
      isDone: json["isDone"],
    );
  }

  @override
  Map<String, dynamic> toJson(Todo entity) {
    return {
      "id": entity.id,
      "name": entity.name,
      "isDone": entity.isDone,
    };
  }
}

class SubTodoRepository extends LocalStorageRepository<int, SubTodo> {
  SubTodoRepository(super.controller, super.localStorageHandler);

  @override
  SubTodo fromJson(Map<String, dynamic> json) {
    return SubTodo(
      id: json["id"],
      todoId: json["todoId"],
      name: json["name"],
      isDone: json["isDone"],
    );
  }

  @override
  Map<String, dynamic> toJson(SubTodo entity) {
    return {
      "id": entity.id,
      "todoId": entity.todoId,
      "name": entity.name,
      "isDone": entity.isDone,
    };
  }
}

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

  Todo(this.id, this.name, this.isDone);

  factory Todo.create(int id) {
    return Todo(
      id,
      getRandomTodoName(),
      false,
    );
  }

  Todo toggle() {
    return Todo(
      id,
      name,
      isDone ? false : true,
    );
  }
}

class TodoRepository extends LocalStorageRepository<int, Todo> {
  TodoRepository(super.controller, super.localStorageHandler);

  @override
  Todo fromJson(Map<String, dynamic> json) {
    return Todo(json["id"], json["name"], json["isDone"]);
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

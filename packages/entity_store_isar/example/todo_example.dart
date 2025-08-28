import 'package:entity_store/entity_store.dart';
import 'package:entity_store_isar/entity_store_isar.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Entity definition
class TodoEntity extends Entity<String> {
  @override
  final String id;
  final String title;
  final String description;
  final bool completed;
  final DateTime createdAt;

  TodoEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.createdAt,
  });

  TodoEntity copyWith({
    String? title,
    String? description,
    bool? completed,
  }) {
    return TodoEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt,
    );
  }
}

// Isar Model with code generation annotations
@collection
class TodoModel {
  IsarId id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String entityId;
  
  late String title;
  late String description;
  late bool completed;
  late DateTime createdAt;
}

// Repository implementation
class TodoIsarRepository extends IsarRepository<String, TodoEntity, TodoModel> {
  TodoIsarRepository({
    required Isar isar,
    required EntityStoreController controller,
  }) : super(isar, controller);

  @override
  IsarCollection<TodoModel> getCollection() {
    return isar.todoModels;
  }

  @override
  TodoEntity toEntity(TodoModel model) {
    return TodoEntity(
      id: model.entityId,
      title: model.title,
      description: model.description,
      completed: model.completed,
      createdAt: model.createdAt,
    );
  }

  @override
  TodoModel fromEntity(TodoEntity entity) {
    return TodoModel()
      ..entityId = entity.id
      ..title = entity.title
      ..description = entity.description
      ..completed = entity.completed
      ..createdAt = entity.createdAt;
  }

  @override
  String idToString(String id) {
    return id;
  }
}

// Example usage
void main() async {
  // Initialize Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [TodoModelSchema],
    directory: dir.path,
  );

  // Create EntityStore controller
  final controller = EntityStoreController();

  // Create repository
  final todoRepository = TodoIsarRepository(
    isar: isar,
    controller: controller,
  );

  // Example: Save a todo
  final todo = TodoEntity(
    id: '1',
    title: 'Buy groceries',
    description: 'Milk, eggs, bread',
    completed: false,
    createdAt: DateTime.now(),
  );

  await todoRepository.save(todo);
  print('Todo saved: ${todo.title}');

  // Example: Find by ID
  final foundTodo = await todoRepository.findById('1');
  if (foundTodo != null) {
    print('Found todo: ${foundTodo.title}');
  }

  // Example: Query with filters
  final completedTodos = await todoRepository
      .query()
      .where('completed', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .limit(10)
      .findAll();

  print('Found ${completedTodos.length} completed todos');

  // Example: Update a todo
  if (foundTodo != null) {
    final updatedTodo = foundTodo.copyWith(completed: true);
    await todoRepository.save(updatedTodo);
    print('Todo marked as completed');
  }

  // Example: Delete a todo
  await todoRepository.deleteById('1');
  print('Todo deleted');

  // Example: Count todos
  final count = await todoRepository.count();
  print('Total todos: $count');

  // Close Isar when done
  await isar.close();
}
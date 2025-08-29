# entity_store_isar

Isar database integration for the EntityStore state management ecosystem.

## Overview

`entity_store_isar` provides a high-performance local database backend for EntityStore using the [Isar](https://isar.dev/) database. This package enables offline-first Flutter applications with reactive state management and efficient local data persistence.

## Features

- 🚀 **High Performance**: Leverages Isar's efficient native database engine
- 💾 **Local Persistence**: Full offline support with automatic data persistence
- 🔍 **Advanced Queries**: Support for complex queries with filters, sorting, and pagination
- 🔄 **Reactive Updates**: Automatic UI synchronization when entities change
- 🏗️ **Type Safety**: Full type safety with code generation
- 🔐 **Transaction Support**: ACID compliant transactions for data integrity

## Installation

Add `entity_store_isar` to your `pubspec.yaml`:

```yaml
isar_version: &isar_version 3.2.0-dev.2

dependencies:
  entity_store_isar: ^6.0.0
  entity_store: ^6.0.0
  isar_community: *isar_version
  isar_community_flutter_libs: *isar_version

dev_dependencies:
  build_runner: any
  isar_community_generator: *isar_version
```

## Usage

### 1. Define Your Entity

```dart
import 'package:entity_store/entity_store.dart';

class TodoEntity extends Entity<String> {
  @override
  final String id;
  final String title;
  final bool completed;
  final DateTime createdAt;

  TodoEntity({
    required this.id,
    required this.title,
    required this.completed,
    required this.createdAt,
  });
}
```

### 2. Create Isar Model

```dart
import 'package:isar_community/isar_community.dart';

@collection
class TodoModel {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String entityId;
  
  late String title;
  late bool completed;
  late DateTime createdAt;
}
```

### 3. Implement Repository

```dart
import 'package:entity_store_isar/entity_store_isar.dart';

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
      completed: model.completed,
      createdAt: model.createdAt,
    );
  }

  @override
  TodoModel fromEntity(TodoEntity entity) {
    return TodoModel()
      ..entityId = entity.id
      ..title = entity.title
      ..completed = entity.completed
      ..createdAt = entity.createdAt;
  }

  @override
  String idToString(String id) => id;
}
```

### 4. Initialize and Use

```dart
// Initialize Isar
final dir = await getApplicationDocumentsDirectory();
final isar = await Isar.open(
  [TodoModelSchema],
  directory: dir.path,
);

// Create repository
final controller = EntityStoreController();
final todoRepository = TodoIsarRepository(
  isar: isar,
  controller: controller,
);

// Use repository
final todo = TodoEntity(
  id: '1',
  title: 'Buy groceries',
  completed: false,
  createdAt: DateTime.now(),
);

await todoRepository.save(todo);
```

### 5. Query Data

```dart
// Find by ID
final todo = await todoRepository.findById('1');

// Query with filters
final completedTodos = await todoRepository
    .query()
    .where('completed', isEqualTo: true)
    .orderBy('createdAt', descending: true)
    .limit(10)
    .findAll();

// Count entities
final count = await todoRepository.count();
```

### 6. Integrate with Flutter UI

```dart
@override
Widget build(BuildContext context) {
  return EntityStoreProviderScope(
    repositories: [todoRepository],
    child: MaterialApp(
      home: TodoList(),
    ),
  );
}

// In your widget
class TodoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final todos = context.watchAll<String, TodoEntity>();
    
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return ListTile(
          title: Text(todo.title),
          trailing: Checkbox(
            value: todo.completed,
            onChanged: (_) => // Update todo
          ),
        );
      },
    );
  }
}
```

## Code Generation

Run build_runner to generate Isar collection code:

```bash
flutter pub run build_runner build
```

## Query Operators

The repository supports various query operators:

- **Equality**: `isEqualTo`, `isNotEqualTo`
- **Comparison**: `isLessThan`, `isLessThanOrEqualTo`, `isGreaterThan`, `isGreaterThanOrEqualTo`
- **Array**: `arrayContains`
- **Null checks**: `isNull`
- **Sorting**: `orderBy` with ascending/descending options
- **Limiting**: `limit` for pagination

## Transactions

Currently, transactions are handled automatically by Isar. All write operations (save, delete) are wrapped in transactions.

## Limitations

Some EntityStore features are not yet fully implemented in this Isar integration:

- `watchById` and `watchAll` streams (reactive watching)
- `arrayContainsAny`, `whereIn`, `whereNotIn` operators
- `startAfter` for cursor-based pagination
- Custom transaction contexts

These features will be added in future versions.

## Example

See the `/example` folder for a complete Todo application demonstrating all features.

## License

This package follows the same license as the main entity_store package.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests on the [GitHub repository](https://github.com/soraef/entity_store).

## Related Packages

- [entity_store](https://pub.dev/packages/entity_store) - Core EntityStore package
- [entity_store_firestore](https://pub.dev/packages/entity_store_firestore) - Firebase Firestore integration
- [entity_store_sembast](https://pub.dev/packages/entity_store_sembast) - Sembast database integration
[English](README.md) | [日本語](README_JA.md)

# EntityStore Ecosystem

## Overview

**EntityStore** is a comprehensive state management ecosystem for Flutter application development based on entity-centric design philosophy. It encapsulates business logic within immutable entities, provides abstracted data access through repository patterns, and achieves reactive UI synchronization.

### 🎯 Design Philosophy

EntityStore is designed based on three core principles:

1. **Entity-First Design**: Architecture centered around business objects (entities) that form the core of the application
2. **Immutability Principle**: State changes only through creation of new instances, preventing unexpected side effects  
3. **Reactive Synchronization**: Seamless development experience where data changes automatically reflect in the UI

## 📦 Package Composition

The EntityStore ecosystem consists of three packages that can be selected based on your use case:

### 🏛️ entity_store (Core Package)
```yaml
dependencies:
  entity_store: ^6.0.0-dev.13
```
- **Role**: Foundation for entity-based state management
- **Features**: Entity abstraction, reactive UI synchronization, basic repository patterns
- **Use Cases**: In-memory state management, prototyping, testing environments

### 🔥 entity_store_firestore
```yaml
dependencies:
  entity_store_firestore: ^6.0.0-dev.15
```
- **Role**: Integration with Firebase Firestore
- **Features**: Cloud synchronization, real-time updates, offline support, transaction processing
- **Use Cases**: Multi-device synchronization, real-time collaboration, scalable web apps

### 💾 entity_store_sembast  
```yaml
dependencies:
  entity_store_sembast: ^6.0.0-dev.13
```
- **Role**: Integration with Sembast (NoSQL local database)
- **Features**: High-performance local storage, complex queries, data encryption support
- **Use Cases**: Offline-first apps, high-speed local processing, privacy-focused applications

## ✨ Key Benefits

### 🚀 Enhanced Development Efficiency
```dart
// Simple entity operations
final todo = context.watchOne<int, Todo>(todoId)!;
return CheckboxListTile(
  title: Text(todo.name),
  value: todo.isDone,
  onChanged: (value) => todoRepository.save(todo.toggle()),
);
```

### 🔄 Automatic UI Synchronization
Entity changes are automatically reflected throughout the UI. No need to write complex state management code.

### 🏗️ Flexible Architecture
```dart
// Development: In-memory
final repository = TodoRepository(controller, InMemoryStorageHandler());

// Production: Firestore
final repository = TodoFirestoreRepository(controller, firestore);

// Local-focused: Sembast
final repository = TodoSembastRepository(controller, database);
```

### 🔒 Type Safety
TypeScript-like type safety allows compile-time error detection.

## 🎯 Usage Example: Todo Application

### Entity Definition
```dart
class Todo implements Entity<int> {
  @override
  final int id;
  final String name;
  final bool isDone;
  final DateTime createdAt;

  const Todo({
    required this.id,
    required this.name,
    required this.isDone,
    required this.createdAt,
  });

  // Create a new Todo
  factory Todo.create(int id, String name) {
    return Todo(
      id: id,
      name: name,
      isDone: false,
      createdAt: DateTime.now(),
    );
  }

  // Toggle completion status
  Todo toggle() => Todo(
    id: id,
    name: name,
    isDone: !isDone,
    createdAt: createdAt,
  );

  // Update name
  Todo rename(String newName) => Todo(
    id: id,
    name: newName,
    isDone: isDone,
    createdAt: createdAt,
  );
}
```

### Repository Implementation (Firestore Version)
```dart
class TodoFirestoreRepository extends FirestoreRepository<int, Todo> {
  TodoFirestoreRepository(super.controller, super.instance);

  @override
  String get collectionId => 'todos';

  @override
  String idToString(int id) => id.toString();

  @override
  Todo fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int,
      name: json['name'] as String,
      isDone: json['isDone'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson(Todo entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'isDone': entity.isDone,
      'createdAt': entity.createdAt.toIso8601String(),
    };
  }
}
```

### UI Implementation
```dart
class TodoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Watch all todos
    final todos = context.watchAll<int, Todo>();
    
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos.values.elementAt(index);
        return TodoTile(todoId: todo.id);
      },
    );
  }
}

class TodoTile extends StatelessWidget {
  final int todoId;
  
  const TodoTile({required this.todoId});

  @override
  Widget build(BuildContext context) {
    // Watch specific todo
    final todo = context.watchOne<int, Todo>(todoId);
    
    if (todo == null) return const SizedBox.shrink();
    
    return ListTile(
      title: Text(todo.name),
      leading: Checkbox(
        value: todo.isDone,
        onChanged: (_) {
          // Entity update (automatic UI sync)
          todoRepository.save(todo.toggle());
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          // Entity deletion (automatic UI update)
          todoRepository.deleteById(todo.id);
        },
      ),
    );
  }
}
```

### Application Setup
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EntityStoreProviderScope(
      entityStoreNotifier: entityStoreNotifier,
      child: MaterialApp(
        title: 'EntityStore Todo',
        home: TodoHomePage(),
      ),
    );
  }
}
```

## 🎨 Advanced Features

### Reactive Queries
```dart
// Watch only incomplete todos
final activeTodos = context.watchAll<int, Todo>(
  (todo) => !todo.isDone,
);

// Watch count of completed todos
final completedCount = context.selectAll<int, Todo, int>(
  (todos) => todos.values.where((todo) => todo.isDone).length,
);
```

### Efficient Data Fetching
```dart
// Pagination support
final todos = await todoRepository
  .query()
  .orderBy('createdAt', descending: true)
  .limit(20)
  .findAll();

// Conditional search
final urgentTodos = await todoRepository
  .query()
  .where('priority', isEqualTo: 'high')
  .where('isDone', isEqualTo: false)
  .findAll();
```

### Transaction Processing (Firestore)
```dart
await todoRepository.transaction((transaction) async {
  final todo = await transaction.findById(todoId);
  if (todo != null) {
    await transaction.save(todo.toggle());
    await transaction.save(createLogEntry(todo));
  }
});
```

## 🔧 Getting Started

### 1. Package Selection and Installation
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Core package (required)
  entity_store: ^6.0.0-dev.13
  
  # Choose based on your needs
  entity_store_firestore: ^6.0.0-dev.15  # Cloud sync
  entity_store_sembast: ^6.0.0-dev.13    # Local DB
```

### 2. Basic Setup
```dart
// Initialize entity store
final entityStoreNotifier = EntityStoreNotifier();
final entityStoreController = EntityStoreController(entityStoreNotifier);

// Repository setup (example: Firestore)
final firestore = FirebaseFirestore.instance;
final todoRepository = TodoFirestoreRepository(
  entityStoreController,
  firestore,
);
```

### 3. Dependency Injection (Recommended)
```dart
// Example using Riverpod
final entityStoreProvider = Provider((ref) => EntityStoreNotifier());

final entityStoreControllerProvider = Provider((ref) => 
  EntityStoreController(ref.watch(entityStoreProvider)));

final todoRepositoryProvider = Provider((ref) => 
  TodoFirestoreRepository(
    ref.watch(entityStoreControllerProvider),
    FirebaseFirestore.instance,
  ));
```

## 🌟 Package Selection Guide

| Requirements              | Recommended Package      | Reasons                                 |
| ------------------------- | ------------------------ | --------------------------------------- |
| 🧪 Prototyping & Learning  | `entity_store`           | Simple, lightweight, low learning curve |
| 🌐 Real-time Collaboration | `entity_store_firestore` | Auto-sync, scalability                  |
| 📱 Offline-first Apps      | `entity_store_sembast`   | Fast, offline support, privacy          |
| 🏢 Enterprise Apps         | Combined usage           | Hybrid configuration as needed          |

## 🚀 Next Steps

1. **[Quick Start Guide](./docs/getting-started.md)** - Experience EntityStore in 5 minutes
2. **[Architecture Guide](./docs/architecture.md)** - Detailed explanation of design philosophy
3. **[Best Practices](./docs/best-practices.md)** - Practical development know-how
4. **[Migration Guide](./docs/migration.md)** - Migration from existing projects

## 🤝 Community

- **GitHub**: [soraef/entity_store](https://github.com/soraef/entity_store)
- **Discord**: [EntityStore Community](https://discord.gg/entitystore)
- **Issues**: Bug reports & feature requests at [GitHub Issues](https://github.com/soraef/entity_store/issues)

## 📄 License

This project is released under the [MIT License](LICENSE).
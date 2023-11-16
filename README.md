[English](/docs/entity_store/en/README.md) | [日本語](/docs/entity_store/ja/README.md)

# EntityStore Package
## Introduction
EntityStore enhances Flutter application development by offering state management centered around entities. This library encapsulates the application's business logic within immutable entities and maintains UI consistency through centralized state management.

The following TodoTile component example demonstrates how EntityStore connects UI components with their state.

```dart
class TodoTile extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    // Monitor a specific Todo
    final todo = context.watchOne<int, Todo>(todoId)!;

    // Toggle the completion state of Todo
    return CheckboxListTile(
      title: Text(todo.name),
      value: todo.isDone,
      onChanged: (bool? value) {
        if (value != null) {
          todoRepository.save(todo.toggle());
        }
      },
    );
  }
}
```

## Features
- **Reactive UI Synchronization**: EntityStore reflects state changes reactively on the UI. In the code example above, the `watchOne` method is used to monitor a specific Todo entity, and updates the checkbox display when its state changes.
- **Concise State Updates**: The state of an entity is updated through a new instance only when necessary. Toggling the completion state of a Todo is easily done by calling `todo.toggle()`, and the result is persisted through the repository.
- **Central Handling of Entities**: EntityStore focuses on the entities that form the core part of the application, allowing developers to concentrate on business logic.
- **Flexible Database Integration**: EntityStore facilitates the integration with external data sources. By swapping out repository implementations, it is possible to connect with Firebase Firestore, local databases, or other data storages.
- **Boilerplate Reduction**: The use of pre-prepared repository implementations eliminates the need for developers to write repetitive database operation code. This accelerates the development process and eases the maintenance of applications.
## Installation
To introduce the EntityStore package into your Flutter project, add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  entity_store: latest_version
```

## Usage
The following sample code demonstrates the implementation of a Todo application using EntityStore.

### Definition of the Todo Entity

An entity encapsulates core business logic in your application and has a unique identifier (ID). This enables entities to be identifiable throughout the application, maintaining data integrity. In EntityStore, entities are designed to be immutable. This is important for detecting changes in entity states and ensuring they are appropriately reflected in the UI.

The `Todo` class is an example that implements this concept. Each `Todo` item has a unique ID, a name, and a completion status attribute. The `create` factory method allows you to create a new `Todo` instance with a random name. The `toggle` method is used to toggle the completion status of a `Todo`, returning a new `Todo` instance with the updated status.

```dart
class Todo implements Entity<int> {
  // Entity attributes must be immutable.
  @override
  final int id;
  final String name;
  final bool isDone;

  Todo(this.id, this.name, this.isDone);

  // Create a new Todo entity
  factory Todo.create(int id) {
    return Todo(
      id,
      getRandomTodoName(),
      false,
    );
  }

  // Toggle the completion status of a Todo entity
  Todo toggle() {
    return Todo(
      id,
      name,
      !isDone,
    );
  }
}
```

This immutable design approach allows each instance of `Todo` to be reusable, and state changes can only be made through the creation of new instances, preventing unexpected side effects and making state management more predictable. It also reduces complexity when detecting entity changes and updating the UI, improving the maintainability of the application.

### Implementation of the Todo Repository
One of the powerful features of EntityStore is the implementation of the repository pattern. Following this pattern, the `TodoRepository` extends `LocalStorageRepository` and defines its own handling of saving, reading, and deleting entities by overriding inherited methods.

The `TodoRepository` is a specific implementation of the `LocalStorageRepository` for `Todo` entities. It overrides the `fromJson` and `toJson` methods for reading and saving JSON data, making it easy to convert between entities and data storage.

```dart
class TodoRepository extends LocalStorageRepository<int, Todo> {
  TodoRepository(super.controller, super.localStorageHandler);

  @override
  Todo fromJson(Map<String, dynamic> json) {
    // Create a Todo entity from JSON
  }

  @override
  Map<String, dynamic> toJson(Todo entity) {
    // Convert a Todo entity to JSON
  }
}
```

#### About `LocalStorageHandler`
The EntityStore package provides `InMemoryStorageHandler` by default, which is a simple storage handler that stores data only in memory. This allows for easy state management during development and testing. However, in a real application, you can implement a custom `LocalStorageHandler` to store data in the device's local storage.

```dart
class InMemoryStorageHandler extends LocalStorageHandler {
  // Data operations in memory
}
```

## Setup of EntityStore

To set up EntityStore, initialize `EntityStoreNotifier` or `EntityStoreController`, and associate them with the repository as follows:

```dart
final entityStoreNotifier = EntityStoreNotifier();
final entityStoreController = EntityStoreController(entityStoreNotifier);
final storageHandler = InMemoryStorageHandler();
final todoRepository = TodoRepository(entityStoreController, storageHandler);
```

While the code snippet above uses global variables for simplicity, it is recommended to use dependency injection (DI) using containers like Riverpod's `Provider` or GetIt for a more robust design. By doing so, you can efficiently resolve dependencies needed by different parts of your application, improving testability and code reusability.

Example:

```dart
final entityStoreProvider = Provider((ref) => EntityStoreNotifier());
final entityStoreControllerProvider = Provider((ref) => EntityStoreController(ref.watch(entityStoreProvider)));
// ...

// In other parts of the application
final entityStoreNotifier = ref.watch(entityStoreProvider);
final entityStoreController = ref.watch(entityStoreControllerProvider);
```

By adopting this approach, you make dependencies required by various parts of your application more explicit and achieve a design that is resilient to changes and extensions.

### Usage in UI

#### Setup of EntityStoreProviderScope

The first step in using the EntityStore package is to set up an `EntityStoreProviderScope` at the top level of your application. This creates a foundation for monitoring and sharing state changes throughout the entire application.

```dart
class MyApp extends StatelessWidget {
  // ...

  @override
  Widget build(BuildContext context) {
    // Place the EntityStoreProviderScope at the root of the app
    return EntityStoreProviderScope(
      entityStoreNotifier: entityStoreNotifier,
      child: MaterialApp(
        // ...
      ),
    );
  }
}
```

#### Monitoring State and Updating UI

You can use `selectAll` to retrieve the IDs of all Todo entities and display them as a list in the UI. This way, you monitor the entire Todo list and update the list whenever a new Todo is added.

`context.watchOne` monitors specific entities. By utilizing these methods, changes in state are automatically reflected in the UI.

```dart
class MyHomePage extends StatefulWidget {
  // ...

  @override
  Widget build(BuildContext context) {
    // Get IDs of all Todos
    final todoIds = context.selectAll<int, Todo, List<int>>(
      (value) => value.ids.toList(),
    );

    // ...
  }
}
```

#### Performing Entity Operations and UI Consistency

When you manipulate entities through the repository, the state in `EntityStore` is updated, and related UI components are automatically updated.

```dart
class TodoTile extends StatelessWidget {
  // ...

  @override
  Widget build(BuildContext context) {
    // Monitor a specific Todo
    final todo = context.watchOne<int, Todo>(todoId);

    // Toggle the completion status of Todo
    return CheckboxListTile(
      title: Text(todo.name),
      value: todo.isDone,
      onChanged: (bool? value) {
       

 if (value != null) {
          // Update the entity through the repository
          todoRepository.save(todo.toggle());
        }
      },
    );
  }
}
```

## Details of State Management Methods and Usage Examples

The `watch`, `select`, and `read` methods provided by EntityStore are essential tools for monitoring application state and updating the UI accordingly. These methods help maintain synchronization between the state managed by EntityStore and UI components.

### Usage of the `watch` Method

You can use the `watchAll` method to monitor only incomplete Todos in real-time and update the list whenever changes occur.

```dart
final activeTodos = context.watchAll<int, Todo>(
  (todo) => !todo.isDone,
);

ListView.builder(
  itemCount: activeTodos.length,
  itemBuilder: (context, index) {
    final todo = activeTodos.values.elementAt(index);
    return ListTile(
      title: Text(todo.name),
      leading: Checkbox(
        value: todo.isDone,
        onChanged: (bool? checked) {
          // Logic to update the completion status of Todo
        },
      ),
    );
  },
);
```

You can use the `watchOne` method to monitor changes in the state of a specific Todo entity and update only that Todo.

```dart
final todo = context.watchOne<int, Todo>(todoId);

if (todo != null) {
  return CheckboxListTile(
    title: Text(todo.name),
    value: todo.isDone,
    onChanged: (bool? newValue) {
      // Logic to update the state of Todo
    },
  );
}
```

### Usage of the `select` Method

You can use the `selectAll` method to retrieve specific data (e.g., names) from the entire Todo list and display only that data.

```dart
final todoNames = context.selectAll<int, Todo, List<String>>(
  (todos) => todos.values.map((todo) => todo.name).toList(),
);

ListView(
  children: todoNames.map((name) => Text(name)).toList(),
);
```

You can use the `selectOne` method to retrieve specific data from a single Todo and update a widget that displays that data when the name of the Todo changes.

```dart
final todoName = context.selectOne<int, Todo, String>(
  todoId,
  (todo) => todo.name,
);

Text(todoName ?? 'No name');
```

### Usage of the `read` Method

You can use the `readAll` method to retrieve all Todos once during the initial load of the screen and use the data without triggering a rebuild.

```dart
final allTodos = context.readAll<int, Todo>();

// Display all Todos during the initial load
ListView(
  children: allTodos.values.map((todo) => Text(todo.name)).toList(),
);
```

You can use the `readOne` method to perform a one-time data read based on a user action, such as displaying Todo details in a dialog.

```dart
final todo = context.readOne<int, Todo>(todoId);

// Display a dialog triggered by a user action
showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: Text(todo?.name ?? 'No name'),
      content: Text('Completed: ${todo?.isDone}'),
    );
  },
);
```

By using these methods, you can efficiently read and update state in EntityStore while ensuring that changes in the state of your application are reflected in the UI as needed.

### Usage of Repositories

Repositories are designed to abstract data source operations and separate business logic from data access code. In EntityStore, operations on entities performed through repositories are automatically reflected in the UI. This means that when you save, update, or delete entities through a repository, these changes are automatically propagated to the UI, allowing users to immediately see the latest state.

This behavior is achieved by using reactive methods like `watch`, `select`, etc., in combination with EntityStore, which ensures synchronization between the state managed by EntityStore and UI components. Below are basic repository operations and their usage examples.

#### findById

Get an entity with the specified ID.

```dart
// Example: Finding a Todo by ID
var result = await todoRepository.findById(todoId);
if (result.isOk) {
  var todo = result.ok;
  // Perform Todo-related operations here
}
```

#### findAll

Retrieve all entities.

```dart
// Example: Get all Todos that meet specific criteria
var result = await todoRepository.query()
  .where('isComplete', isEqualTo: false)
  .findAll();
if (result.isOk) {
  var todos = result.ok;
  // Perform operations on the Todo list here
}
```

#### findOne

Retrieve the first entity that matches the specified criteria.

```dart
// Example: Find the first Todo that meets specific criteria
var result = await todoRepository.query()
  .where('isComplete', isEqualTo: false)
  .findOne();
if (result.isOk) {
  var todo = result.ok;
  // Perform Todo-related operations here
}
```

#### count

Count the number of entities that match the specified criteria.

```dart
// Example: Count the number of incomplete Todos
var result = await todoRepository.query()
  .where('isComplete', isEqualTo: false)
  .count();
if (result.isOk) {
  var activeCount = result.ok;
  // Perform operations using activeCount here
}
```

#### save

Save or update an entity.

```dart
// Example: Save a new Todo
var newTodo = Todo.create(name: 'New Task');
var result = await todoRepository.save(newTodo);
if (result.isOk) {
  // Handle the success of the save operation here
}
```

#### delete

Delete an entity.

```dart
// Example: Delete a Todo
var result = await todoRepository.delete(todoId);
if (result.isOk) {
  // Handle the success of the delete operation here
}
```

#### upsert

Create a new entity if it doesn't exist or update it if it does.

```dart
// Example: Upsert a Todo
var result = await todoRepository.upsert(
  todoId,
  creater: () => Todo.create(name: 'New Task'),
  updater: (existingTodo) => existingTodo.copyWith(isComplete: true),
);
if (result.isOk) {
  // Handle the success of the upsert operation here
}
```

Through these operations, the application can efficiently manage data within EntityStore and maintain data consistency.

## License
This project is released under the MIT license. Please refer to the LICENSE file for details.
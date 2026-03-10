import 'package:entity_store/src/entity_store.dart';
import 'package:flutter_test/flutter_test.dart';

class User extends Entity<String> {
  @override
  final String id;
  final String name;

  User({required this.id, required this.name});
}

class Task extends Entity<int> {
  @override
  final int id;
  final String title;

  Task({required this.id, required this.title});
}

class TestStore with EntityStoreMixin {
  EntityStore state = EntityStore.empty();

  @override
  void update(Updater<EntityStore> updater) {
    state = updater(state);
  }

  @override
  EntityStore get value => state;
}

void main() {
  late TestStore store;
  late EntityStoreController controller;

  setUp(() {
    store = TestStore();
    controller = EntityStoreController(store);
  });

  group('EntityStoreController basic operations', () {
    test('put adds entity to store', () {
      final user = User(id: '1', name: 'Alice');
      controller.put<String, User>(user);
      expect(controller.getById<String, User>('1')?.name, 'Alice');
    });

    test('delete removes entity from store', () {
      final user = User(id: '1', name: 'Alice');
      controller.put<String, User>(user);
      controller.delete<String, User>('1');
      expect(controller.getById<String, User>('1'), null);
    });

    test('getAll returns all entities of type', () {
      controller.put<String, User>(User(id: '1', name: 'Alice'));
      controller.put<String, User>(User(id: '2', name: 'Bob'));
      final all = controller.getAll<String, User>();
      expect(all.length, 2);
    });

    test('where filters entities', () {
      controller.put<String, User>(User(id: '1', name: 'Alice'));
      controller.put<String, User>(User(id: '2', name: 'Bob'));
      final filtered = controller.where<String, User>((u) => u.name == 'Alice');
      expect(filtered.length, 1);
      expect(filtered.byId('1')!.name, 'Alice');
    });

    test('clearAll removes all entities', () {
      controller.put<String, User>(User(id: '1', name: 'Alice'));
      controller.put<int, Task>(Task(id: 1, title: 'Task 1'));
      controller.clearAll();
      expect(controller.getAll<String, User>(), isEmpty);
      expect(controller.getAll<int, Task>(), isEmpty);
    });

    test('multiple entity types coexist', () {
      controller.put<String, User>(User(id: '1', name: 'Alice'));
      controller.put<int, Task>(Task(id: 1, title: 'Task 1'));
      expect(controller.getById<String, User>('1')?.name, 'Alice');
      expect(controller.getById<int, Task>(1)?.title, 'Task 1');
    });
  });

  group('EntityStoreController dispatch', () {
    test('dispatch GetEvent adds entity', () {
      final user = User(id: '1', name: 'Alice');
      controller.dispatch(GetEvent<String, User>.now('1', user));
      expect(controller.getById<String, User>('1'), user);
    });

    test('dispatch GetEvent with null removes entity', () {
      final user = User(id: '1', name: 'Alice');
      controller.put<String, User>(user);
      controller.dispatch(GetEvent<String, User>.now('1', null));
      expect(controller.getById<String, User>('1'), null);
    });

    test('dispatch SaveEvent adds entity', () {
      final user = User(id: '1', name: 'Alice');
      controller.dispatch(SaveEvent<String, User>.now(user));
      expect(controller.getById<String, User>('1'), user);
    });

    test('dispatch DeleteEvent removes entity', () {
      final user = User(id: '1', name: 'Alice');
      controller.put<String, User>(user);
      controller.dispatch(DeleteEvent<String, User>.now('1'));
      expect(controller.getById<String, User>('1'), null);
    });

    test('dispatch ListEvent adds multiple entities', () {
      final users = [
        User(id: '1', name: 'Alice'),
        User(id: '2', name: 'Bob'),
      ];
      controller.dispatch(ListEvent<String, User>.now(users));
      expect(controller.getAll<String, User>().length, 2);
    });

    test('eventStream emits dispatched events', () async {
      final events = <PersistenceEvent>[];
      controller.eventStream.listen(events.add);

      final user = User(id: '1', name: 'Alice');
      controller.dispatch(SaveEvent<String, User>.now(user));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(events.length, 1);
      expect(events.first, isA<SaveEvent<String, User>>());
    });
  });

  group('EntityStoreController entity events', () {
    test('emits EntityCreatedEvent when new entity is added', () async {
      final events = <EntityEvent>[];
      controller.entityEventStream.listen(events.add);

      controller.dispatch(
          SaveEvent<String, User>.now(User(id: '1', name: 'Alice')));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(events.length, 1);
      expect(events.first, isA<EntityCreatedEvent<String, User>>());
    });

    test('emits EntityUpdatedEvent when existing entity is updated', () async {
      final events = <EntityEvent>[];
      controller.put<String, User>(User(id: '1', name: 'Alice'));

      controller.entityEventStream.listen(events.add);

      controller.dispatch(
          SaveEvent<String, User>.now(User(id: '1', name: 'Updated')));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(events.length, 1);
      expect(events.first, isA<EntityUpdatedEvent<String, User>>());
    });

    test('emits EntityDeletedEvent when entity is removed', () async {
      final events = <EntityEvent>[];
      controller.put<String, User>(User(id: '1', name: 'Alice'));

      controller.entityEventStream.listen(events.add);

      controller.dispatch(DeleteEvent<String, User>.now('1'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(events.length, 1);
      expect(events.first, isA<EntityDeletedEvent<String, User>>());
    });
  });

  group('EntityStoreController.empty', () {
    test('empty controller does not store entities', () {
      final emptyController = EntityStoreController.empty();
      emptyController.dispatch(
          SaveEvent<String, User>.now(User(id: '1', name: 'Alice')));
      expect(emptyController.getById<String, User>('1'), null);
    });
  });
}

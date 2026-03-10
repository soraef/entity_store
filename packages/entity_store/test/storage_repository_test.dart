import 'package:entity_store/entity_store.dart';
import 'package:flutter_test/flutter_test.dart';

class Todo extends Entity<String> {
  @override
  final String id;
  final String title;
  final bool done;

  Todo({required this.id, required this.title, this.done = false});

  Todo toggle() => Todo(id: id, title: title, done: !done);
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

class TestDataSourceHandler extends IDataSourceHandler<String, Todo> {
  final Map<String, Todo> _data = {};

  @override
  Future<void> save(Todo entity) async {
    _data[entity.id] = entity;
  }

  @override
  Future<void> saveAll(Iterable<Todo> entities) async {
    for (final entity in entities) {
      _data[entity.id] = entity;
    }
  }

  @override
  Future<List<Todo>> loadAll() async {
    return _data.values.toList();
  }

  @override
  Future<void> delete(String id) async {
    _data.remove(id);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }
}

class TodoRepository extends StorageRepository<String, Todo> {
  TodoRepository({
    required super.dataSourceHandler,
    required super.controller,
  });

  @override
  Map<String, dynamic> toJson(Todo entity) {
    return {
      'id': entity.id,
      'title': entity.title,
      'done': entity.done,
    };
  }

  @override
  Todo fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      done: json['done'] as bool? ?? false,
    );
  }

  @override
  String idToString(String id) => id;
}

void main() {
  late TestStore store;
  late EntityStoreController controller;
  late TestDataSourceHandler dataSource;
  late TodoRepository repository;

  setUp(() {
    store = TestStore();
    controller = EntityStoreController(store);
    dataSource = TestDataSourceHandler();
    repository = TodoRepository(
      dataSourceHandler: dataSource,
      controller: controller,
    );
  });

  group('StorageRepository save', () {
    test('save persists entity and updates store', () async {
      final todo = Todo(id: '1', title: 'Buy milk');
      final result = await repository.save(todo);

      expect(result.id, '1');
      expect(controller.getById<String, Todo>('1')?.title, 'Buy milk');
    });

    test('save overwrites existing entity', () async {
      await repository.save(Todo(id: '1', title: 'Buy milk'));
      await repository.save(Todo(id: '1', title: 'Buy bread'));

      expect(controller.getById<String, Todo>('1')?.title, 'Buy bread');
    });
  });

  group('StorageRepository findById', () {
    test('findById returns entity from data source', () async {
      await repository.save(Todo(id: '1', title: 'Buy milk'));
      final result = await repository.findById('1');

      expect(result?.title, 'Buy milk');
    });

    test('findById returns null for non-existing id', () async {
      final result = await repository.findById('999');
      expect(result, null);
    });

    test('findById with storeOnly reads from store only', () async {
      await repository.save(Todo(id: '1', title: 'Buy milk'));

      // Clear data source but entity should still be in store
      await dataSource.clear();

      final result = await repository.findById(
        '1',
        options: StorageFindByIdOptions(fetchPolicy: FetchPolicy.storeOnly),
      );
      expect(result?.title, 'Buy milk');
    });

    test('findById with storeFirst returns from store if available', () async {
      await repository.save(Todo(id: '1', title: 'Original'));

      // Modify data source directly
      await dataSource.save(Todo(id: '1', title: 'Modified'));

      final result = await repository.findById(
        '1',
        options: StorageFindByIdOptions(fetchPolicy: FetchPolicy.storeFirst),
      );
      // Should return from store, not data source
      expect(result?.title, 'Original');
    });

    test('findById with storeFirst falls through when not in store', () async {
      // Put directly in data source without going through repository
      await dataSource.save(Todo(id: '1', title: 'Direct'));

      final result = await repository.findById(
        '1',
        options: StorageFindByIdOptions(fetchPolicy: FetchPolicy.storeFirst),
      );
      expect(result?.title, 'Direct');
    });
  });

  group('StorageRepository deleteById', () {
    test('deleteById removes entity from data source and store', () async {
      await repository.save(Todo(id: '1', title: 'Buy milk'));
      await repository.deleteById('1');

      expect(controller.getById<String, Todo>('1'), null);
      final loaded = await dataSource.loadAll();
      expect(loaded, isEmpty);
    });

    test('deleteById returns the deleted id', () async {
      await repository.save(Todo(id: '1', title: 'Buy milk'));
      final deletedId = await repository.deleteById('1');
      expect(deletedId, '1');
    });
  });

  group('StorageRepository delete', () {
    test('delete removes entity', () async {
      final todo = Todo(id: '1', title: 'Buy milk');
      await repository.save(todo);
      final result = await repository.delete(todo);
      expect(result.id, '1');
      expect(controller.getById<String, Todo>('1'), null);
    });
  });

  group('StorageRepository upsert', () {
    test('upsert creates when entity does not exist', () async {
      final result = await repository.upsert(
        '1',
        creater: () => Todo(id: '1', title: 'New'),
        updater: (prev) => prev.toggle(),
      );
      expect(result?.title, 'New');
      expect(result?.done, false);
    });

    test('upsert updates when entity exists', () async {
      await repository.save(Todo(id: '1', title: 'Existing'));
      final result = await repository.upsert(
        '1',
        creater: () => Todo(id: '1', title: 'New'),
        updater: (prev) => prev.toggle(),
      );
      expect(result?.done, true);
    });

    test('upsert returns null when creater returns null', () async {
      final result = await repository.upsert(
        '1',
        creater: () => null,
        updater: (prev) => prev.toggle(),
      );
      expect(result, null);
    });
  });

  group('StorageRepository findAll', () {
    test('findAll returns all entities', () async {
      await repository.save(Todo(id: '1', title: 'First'));
      await repository.save(Todo(id: '2', title: 'Second'));

      final result = await repository.findAll();
      expect(result.length, 2);
    });
  });

  group('StorageRepository query', () {
    setUp(() async {
      await repository.save(Todo(id: '1', title: 'Alpha', done: false));
      await repository.save(Todo(id: '2', title: 'Beta', done: true));
      await repository.save(Todo(id: '3', title: 'Gamma', done: false));
    });

    test('query where filters entities', () async {
      final result = await repository
          .query()
          .where('done', isEqualTo: true)
          .findAll();
      expect(result.length, 1);
      expect(result.first.title, 'Beta');
    });

    test('query with limit', () async {
      final result = await repository.query().limit(2).findAll();
      expect(result.length, 2);
    });

    test('query orderBy sorts entities', () async {
      final result = await repository
          .query()
          .orderBy('title', descending: true)
          .findAll();
      expect(result.first.title, 'Gamma');
      expect(result.last.title, 'Alpha');
    });

    test('query findOne returns first match', () async {
      final result = await repository
          .query()
          .where('done', isEqualTo: false)
          .findOne();
      expect(result, isNotNull);
    });

    test('query count returns number of matches', () async {
      final count = await repository
          .query()
          .where('done', isEqualTo: false)
          .count();
      expect(count, 2);
    });

    test('query chaining is immutable', () async {
      final baseQuery = repository.query();
      final filteredQuery = baseQuery.where('done', isEqualTo: true);
      final limitedQuery = baseQuery.limit(1);

      // Each query should be independent
      final filteredResult = await filteredQuery.findAll();
      final limitedResult = await limitedQuery.findAll();

      expect(filteredResult.length, 1);
      expect(limitedResult.length, 1);
    });

    test('query startAfter skips entities', () async {
      final result = await repository.query().startAfter('1').findAll();
      expect(result.length, 2);
      expect(result.first.id, '2');
    });
  });

  group('StorageRepository transaction rejection', () {
    test('findById with transaction throws TransactionException', () async {
      final tx = _DummyTransactionContext();
      expect(
        () => repository.findById('1', transaction: tx),
        throwsA(isA<TransactionException>()),
      );
    });

    test('save with transaction throws TransactionException', () async {
      final tx = _DummyTransactionContext();
      expect(
        () => repository.save(Todo(id: '1', title: 'Test'), transaction: tx),
        throwsA(isA<TransactionException>()),
      );
    });

    test('deleteById with transaction throws TransactionException', () async {
      final tx = _DummyTransactionContext();
      expect(
        () => repository.deleteById('1', transaction: tx),
        throwsA(isA<TransactionException>()),
      );
    });
  });
}

class _DummyTransactionContext extends TransactionContext {
  @override
  Future<void> rollback() async {}
}

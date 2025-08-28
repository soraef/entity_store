import 'package:flutter_test/flutter_test.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_isar/entity_store_isar.dart';
import 'package:isar/isar.dart';

// Test Entity
class TestEntity extends Entity<String> {
  @override
  final String id;
  final String name;
  final int value;

  TestEntity({
    required this.id,
    required this.name,
    required this.value,
  });
}

// Test Isar Model
@collection
class TestModel {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String entityId;
  
  late String name;
  late int value;
}

// Test Repository
class TestIsarRepository extends IsarRepository<String, TestEntity, TestModel> {
  TestIsarRepository({
    required Isar isar,
    required EntityStoreController controller,
  }) : super(isar, controller);

  @override
  IsarCollection<TestModel> getCollection() {
    return isar.collection<TestModel>();
  }

  @override
  TestEntity toEntity(TestModel model) {
    return TestEntity(
      id: model.entityId,
      name: model.name,
      value: model.value,
    );
  }

  @override
  TestModel fromEntity(TestEntity entity) {
    return TestModel()
      ..entityId = entity.id
      ..name = entity.name
      ..value = entity.value;
  }

  @override
  String idToString(String id) {
    return id;
  }
}

void main() {
  group('IsarRepository', () {
    late Isar isar;
    late TestIsarRepository repository;
    late EntityStoreController controller;
    late EntityStore store;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      // For testing, we'll skip the actual Isar initialization
      // since code generation is not working
      // isar = await Isar.open(
      //   [TestModelSchema],
      //   directory: '',
      //   inspector: false,
      // );
      
      // store = EntityStore.empty();
      // controller = EntityStoreController(store);
      // repository = TestIsarRepository(
      //   isar: isar,
      //   controller: controller,
      // );
    });

    tearDown(() async {
      await isar.close();
    });

    test('save and findById', () async {
      final entity = TestEntity(
        id: '1',
        name: 'Test',
        value: 42,
      );

      await repository.save(entity);

      final found = await repository.findById('1');
      expect(found, isNotNull);
      expect(found!.id, equals('1'));
      expect(found.name, equals('Test'));
      expect(found.value, equals(42));
    });

    test('findAll returns all entities', () async {
      final entities = [
        TestEntity(id: '1', name: 'First', value: 1),
        TestEntity(id: '2', name: 'Second', value: 2),
        TestEntity(id: '3', name: 'Third', value: 3),
      ];

      await repository.saveAll(entities);

      final found = await repository.findAll();
      expect(found.length, equals(3));
    });

    test('deleteById removes entity', () async {
      final entity = TestEntity(
        id: '1',
        name: 'ToDelete',
        value: 100,
      );

      await repository.save(entity);
      
      final foundBefore = await repository.findById('1');
      expect(foundBefore, isNotNull);

      await repository.deleteById('1');

      final foundAfter = await repository.findById('1');
      expect(foundAfter, isNull);
    });

    test('query returns basic results', () async {
      final entities = [
        TestEntity(id: '1', name: 'Apple', value: 10),
        TestEntity(id: '2', name: 'Banana', value: 20),
        TestEntity(id: '3', name: 'Cherry', value: 30),
      ];

      await repository.saveAll(entities);

      // For now, basic query without filters
      final result = await repository.query().findAll();

      expect(result.length, equals(3));
    });

    test('query with limit', () async {
      final entities = List.generate(
        10,
        (i) => TestEntity(id: 'id$i', name: 'Item $i', value: i),
      );

      await repository.saveAll(entities);

      final result = await repository
          .query()
          .limit(5)
          .findAll();

      expect(result.length, equals(5));
    });

    test('count returns correct number', () async {
      final entities = List.generate(
        7,
        (i) => TestEntity(id: 'id$i', name: 'Item $i', value: i),
      );

      await repository.saveAll(entities);

      final count = await repository.count();
      expect(count, equals(7));
    });

    test('upsert creates new entity when not exists', () async {
      final result = await repository.upsert(
        'new-id',
        creater: () => TestEntity(id: 'new-id', name: 'New', value: 999),
        updater: (prev) => prev,
      );

      expect(result, isNotNull);
      expect(result!.name, equals('New'));

      final found = await repository.findById('new-id');
      expect(found, isNotNull);
    });

    test('upsert updates existing entity', () async {
      final initial = TestEntity(id: '1', name: 'Initial', value: 100);
      await repository.save(initial);

      final result = await repository.upsert(
        '1',
        creater: () => null,
        updater: (prev) => TestEntity(id: prev.id, name: 'Updated', value: 200),
      );

      expect(result, isNotNull);
      expect(result!.name, equals('Updated'));
      expect(result.value, equals(200));
    });

    test('deleteAll removes all entities', () async {
      final entities = List.generate(
        5,
        (i) => TestEntity(id: 'id$i', name: 'Item $i', value: i),
      );

      await repository.saveAll(entities);
      
      final countBefore = await repository.count();
      expect(countBefore, equals(5));

      await repository.deleteAll();

      final countAfter = await repository.count();
      expect(countAfter, equals(0));
    });

    test('findOne returns first matching entity', () async {
      final entities = [
        TestEntity(id: '1', name: 'First', value: 10),
        TestEntity(id: '2', name: 'Second', value: 20),
        TestEntity(id: '3', name: 'Third', value: 30),
      ];

      await repository.saveAll(entities);

      final result = await repository
          .query()
          .findOne();

      expect(result, isNotNull);
    });
  });
}
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_drift/entity_store_drift.dart';
import 'package:test/test.dart';

part 'entity_store_drift_repository_test.g.dart';

class Task extends Entity<String> {
  @override
  final String id;
  final String title;
  final int priority;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'priority': priority,
        'status': status,
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'] as String,
        title: map['title'] as String,
        priority: map['priority'] as int,
        status: map['status'] as String,
      );
}

class TaskEntries extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get priority => integer()();
  TextColumn get status => text()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@DriftDatabase(tables: [TaskEntries])
class TestDatabase extends _$TestDatabase {
  TestDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

class TaskDriftRepository extends EntityStoreDriftRepository<String, Task> {
  final TestDatabase appDb;

  TaskDriftRepository({
    required super.controller,
    required this.appDb,
  }) : super(db: appDb);

  @override
  Map<String, dynamic> toJson(Task entity) => entity.toMap();

  @override
  Task fromJson(Map<String, dynamic> json) => Task.fromMap(json);

  @override
  String idToString(String id) => id;

  @override
  String idFromString(String idString) => idString;

  @override
  GeneratedColumn columnFor(String fieldName) => switch (fieldName) {
        'id' => appDb.taskEntries.id,
        'title' => appDb.taskEntries.title,
        'priority' => appDb.taskEntries.priority,
        'status' => appDb.taskEntries.status,
        _ => throw ArgumentError('Unknown field: $fieldName'),
      };

  @override
  JoinedSelectStatement buildBaseQuery() {
    return appDb.selectOnly(appDb.taskEntries)
      ..addColumns([
        appDb.taskEntries.id,
        appDb.taskEntries.title,
        appDb.taskEntries.priority,
        appDb.taskEntries.status,
      ]);
  }

  @override
  Task fromRow(TypedResult row) {
    return Task(
      id: row.read(appDb.taskEntries.id)!,
      title: row.read(appDb.taskEntries.title)!,
      priority: row.read(appDb.taskEntries.priority)!,
      status: row.read(appDb.taskEntries.status)!,
    );
  }

  @override
  Future<void> insertOnConflictUpdate(
    Task entity, {
    TransactionContext? transaction,
  }) async {
    await appDb.into(appDb.taskEntries).insertOnConflictUpdate(
          TaskEntriesCompanion(
            id: Value(entity.id),
            title: Value(entity.title),
            priority: Value(entity.priority),
            status: Value(entity.status),
          ),
        );
  }

  @override
  Future<void> deleteFromStore(
    String id, {
    TransactionContext? transaction,
  }) async {
    await (appDb.delete(appDb.taskEntries)..where((tbl) => tbl.id.equals(id)))
        .go();
  }
}

void main() {
  group('EntityStoreDriftRepository', () {
    late TestDatabase db;
    late TaskDriftRepository repository;
    late EntityStoreController controller;

    setUp(() {
      db = TestDatabase(NativeDatabase.memory());
      controller = EntityStoreController.empty();
      repository = TaskDriftRepository(controller: controller, appDb: db);
    });

    tearDown(() async {
      await db.close();
    });

    test('save and findById round-trip', () async {
      await repository.save(
        Task(id: 't1', title: 'Buy milk', priority: 2, status: 'todo'),
      );

      final found = await repository.findById('t1');
      expect(found, isNotNull);
      expect(found!.title, 'Buy milk');
      expect(found.priority, 2);
    });

    test('query uses sql filters and ordering', () async {
      await repository.save(
        Task(id: 't1', title: 'Task 1', priority: 1, status: 'todo'),
      );
      await repository.save(
        Task(id: 't2', title: 'Task 2', priority: 3, status: 'doing'),
      );
      await repository.save(
        Task(id: 't3', title: 'Task 3', priority: 2, status: 'doing'),
      );

      final results = await repository
          .query()
          .where('status', isEqualTo: 'doing')
          .orderBy('priority', descending: true)
          .limit(1)
          .findAll();

      expect(results, hasLength(1));
      expect(results.first.id, 't2');
    });

    test('deleteById removes record', () async {
      await repository.save(
        Task(id: 't1', title: 'Task 1', priority: 1, status: 'todo'),
      );

      await repository.deleteById('t1');

      expect(await repository.findById('t1'), isNull);
    });
  });
}

import 'package:entity_store/entity_store.dart';
import 'package:entity_store_sembast/entity_store_sembast.dart';
import 'package:entity_store_sembast/src/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

class Store with EntityStoreMixin {
  EntityStore state = EntityStore.empty();

  @override
  void update(Updater<EntityStore> updater) {
    state = updater(state);
  }

  @override
  EntityStore get value => state;
}

class TestUser implements Entity<String> {
  @override
  final String id;
  final String name;
  final int age;

  TestUser({
    required this.id,
    required this.name,
    required this.age,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          age == other.age;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ age.hashCode;
}

class TestRepository extends SembastRepository<String, TestUser> {
  TestRepository({
    required super.controller,
    required super.db,
  });

  @override
  String get storeName => 'test_users';

  @override
  TestUser fromJson(Map<String, dynamic> json) {
    return TestUser(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson(TestUser entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'age': entity.age,
    };
  }

  @override
  String idToString(String id) {
    return id;
  }
}

void main() {
  late Database db;
  late EntityStoreController controller;
  late TestRepository repository;

  setUp(() async {
    // メモリ内データベースを初期化
    final factory = databaseFactoryMemory;
    db = await factory.openDatabase('test.db');
    controller = EntityStoreController(Store());
    repository = TestRepository(
      controller: controller,
      db: db,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('SembastRepository', () {
    test('save and findById', () async {
      final user = TestUser(
        id: 'user1',
        name: 'Test User',
        age: 20,
      );

      // 保存
      final savedUser = await repository.save(user);
      expect(savedUser, user);

      // 取得
      final foundUser = await repository.findById(user.id);
      expect(foundUser?.id, user.id);
      expect(foundUser?.name, user.name);
      expect(foundUser?.age, user.age);
    });

    test('findById with non-existent ID', () async {
      final foundUser = await repository.findById('non_existent');
      expect(foundUser, null);
    });

    test('findAll', () async {
      final users = [
        TestUser(id: 'user1', name: 'User 1', age: 20),
        TestUser(id: 'user2', name: 'User 2', age: 25),
      ];

      // 保存
      for (final user in users) {
        await repository.save(user);
      }

      // 全件取得
      final foundUsers = await repository.findAll();
      expect(foundUsers.length, 2);
    });

    test('query with filter', () async {
      final users = [
        TestUser(id: 'user1', name: 'User 1', age: 20),
        TestUser(id: 'user2', name: 'User 2', age: 25),
        TestUser(id: 'user3', name: 'User 3', age: 20),
      ];

      // 保存
      for (final user in users) {
        await repository.save(user);
      }

      // age=20でフィルタリング
      final queryResult =
          await repository.query().where('age', isEqualTo: 20).findAll();
      expect(queryResult.length, 2);
    });

    test('query with sort', () async {
      final users = [
        TestUser(id: 'user1', name: 'User 1', age: 25),
        TestUser(id: 'user2', name: 'User 2', age: 20),
        TestUser(id: 'user3', name: 'User 3', age: 30),
      ];

      // 保存
      for (final user in users) {
        await repository.save(user);
      }

      // age でソート（昇順）
      final queryResult = await repository.query().orderBy('age').findAll();
      expect(queryResult.length, 3);
      expect(queryResult[0].age, 20);
      expect(queryResult[1].age, 25);
      expect(queryResult[2].age, 30);
    });

    test('query with limit', () async {
      final users = [
        TestUser(id: 'user1', name: 'User 1', age: 20),
        TestUser(id: 'user2', name: 'User 2', age: 25),
        TestUser(id: 'user3', name: 'User 3', age: 30),
      ];

      // 保存
      for (final user in users) {
        await repository.save(user);
      }

      // limit を使用
      final queryResult =
          await repository.query().orderBy('id').limit(2).findAll();
      expect(queryResult.length, 2);
      expect(queryResult[0].id, 'user1');
      expect(queryResult[1].id, 'user2');
    });

    test('delete', () async {
      final user = TestUser(
        id: 'user1',
        name: 'Test User',
        age: 20,
      );

      // 保存
      await repository.save(user);

      // 削除
      final deletedUser = await repository.delete(user);
      expect(deletedUser, user);

      // 取得して確認
      final foundUser = await repository.findById(user.id);
      expect(foundUser, null);
    });

    test('count', () async {
      final users = [
        TestUser(id: 'user1', name: 'User 1', age: 20),
        TestUser(id: 'user2', name: 'User 2', age: 25),
        TestUser(id: 'user3', name: 'User 3', age: 20),
      ];

      // 保存
      for (final user in users) {
        await repository.save(user);
      }

      // 全件数を取得
      final count = await repository.count();
      expect(count, 3);

      // フィルタ付きの件数を取得
      final filteredCount =
          await repository.query().where('age', isEqualTo: 20).count();
      expect(filteredCount, 2);
    });

    // test('observeById', () async {
    //   final user = TestUser(
    //     id: 'user1',
    //     name: 'Test User',
    //     age: 20,
    //   );

    //   // 監視を開始
    //   final subscription = repository.observeById(user.id).listen(
    //         expectAsync1((foundUser) {
    //           if (foundUser != null) {
    //             expect(foundUser.id, user.id);
    //             expect(foundUser.name, user.name);
    //             expect(foundUser.age, user.age);
    //           }
    //         }, count: 2), // 初期値nullと保存後の値
    //       );

    //   // 少し待ってから保存
    //   await repository.save(user);

    //   // クリーンアップ
    //   await subscription.cancel();
    // });

    test('fetch policy', () async {
      final user = TestUser(
        id: 'user1',
        name: 'Test User',
        age: 20,
      );

      // 保存
      await repository.save(user);

      // 削除（ストアには残っている状態）
      await repository.delete(user);

      // storeOnly: ストアのみから取得
      final storeOnlyResult = await repository.findById(
        user.id,
        options: EntityStoreFindByIdOptions(
          fetchPolicy: FetchPolicy.storeOnly,
        ),
      );
      expect(storeOnlyResult, null);

      // storeFirst: ストアを優先して取得
      final storeFirstResult = await repository.findById(
        user.id,
        options: EntityStoreFindByIdOptions(
          fetchPolicy: FetchPolicy.storeFirst,
        ),
      );
      expect(storeFirstResult, null);

      // ストアにエンティティを追加
      controller.put(user);

      // storeFirst（キャッシュあり）: キャッシュから取得
      final storeFirstWithCacheResult = await repository.findById(
        user.id,
        options: EntityStoreFindByIdOptions(
          fetchPolicy: FetchPolicy.storeFirst,
        ),
      );
      expect(storeFirstWithCacheResult, user);

      // persistent: 永続化層から取得
      final persistentResult = await repository.findById(
        user.id,
        options: EntityStoreFindByIdOptions(
          fetchPolicy: FetchPolicy.persistent,
        ),
      );
      expect(persistentResult, null);
    });
  });
}

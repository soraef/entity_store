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
    // TODO: implement idToString
    throw UnimplementedError();
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
      final saveResult = await repository.save(user);
      expect(saveResult.isSuccess, true);
      expect(saveResult.success, user);

      // 取得
      final findResult = await repository.findById(user.id);
      expect(findResult.isSuccess, true);
      expect(findResult.success?.id, user.id);
      expect(findResult.success?.name, user.name);
      expect(findResult.success?.age, user.age);
    });

    test('findById with non-existent ID', () async {
      final findResult = await repository.findById('non_existent');
      expect(findResult.isSuccess, true);
      expect(findResult.success, null);
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
      final findResult = await repository.findAll();
      expect(findResult.isSuccess, true);
      expect(findResult.success.length, 2);
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
      expect(queryResult.isSuccess, true);
      expect(queryResult.success.length, 2);
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
      expect(queryResult.isSuccess, true);
      expect(queryResult.success.length, 3);
      expect(queryResult.success[0].age, 20);
      expect(queryResult.success[1].age, 25);
      expect(queryResult.success[2].age, 30);
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
      expect(queryResult.isSuccess, true);
      expect(queryResult.success.length, 2);
      expect(queryResult.success[0].id, 'user1');
      expect(queryResult.success[1].id, 'user2');
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
      final deleteResult = await repository.delete(user);
      expect(deleteResult.isSuccess, true);

      // 取得して確認
      final findResult = await repository.findById(user.id);
      expect(findResult.isSuccess, true);
      expect(findResult.success, null);
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
      final countResult = await repository.count();
      expect(countResult.isSuccess, true);
      expect(countResult.success, 3);

      // フィルタ付きの件数を取得
      final filteredCountResult =
          await repository.query().where('age', isEqualTo: 20).count();
      expect(filteredCountResult.isSuccess, true);
      expect(filteredCountResult.success, 2);
    });

    // test('observeById', () async {
    //   final user = TestUser(
    //     id: 'user1',
    //     name: 'Test User',
    //     age: 20,
    //   );

    //   // 監視を開始
    //   final subscription = repository.observeById(user.id).listen(
    //         expectAsync1((result) {
    //           expect(result!.isSuccess, true);
    //           if (result.success != null) {
    //             expect(result.success?.id, user.id);
    //             expect(result.success?.name, user.name);
    //             expect(result.success?.age, user.age);
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
      expect(storeOnlyResult.isSuccess, true);
      expect(storeOnlyResult.success, null);

      // storeFirst: ストアを優先して取得
      final storeFirstResult = await repository.findById(
        user.id,
        options: EntityStoreFindByIdOptions(
          fetchPolicy: FetchPolicy.storeFirst,
        ),
      );
      expect(storeFirstResult.isSuccess, true);
      expect(storeFirstResult.success, null);

      // ストアにエンティティを追加
      controller.put(user);

      // storeFirst（キャッシュあり）: キャッシュから取得
      final storeFirstWithCacheResult = await repository.findById(
        user.id,
        options: EntityStoreFindByIdOptions(
          fetchPolicy: FetchPolicy.storeFirst,
        ),
      );
      expect(storeFirstWithCacheResult.isSuccess, true);
      expect(storeFirstWithCacheResult.success, user);

      // persistent: 永続化層から取得
      final persistentResult = await repository.findById(
        user.id,
        options: EntityStoreFindByIdOptions(
          fetchPolicy: FetchPolicy.persistent,
        ),
      );
      expect(persistentResult.isSuccess, true);
      expect(persistentResult.success, null);
    });
  });
}

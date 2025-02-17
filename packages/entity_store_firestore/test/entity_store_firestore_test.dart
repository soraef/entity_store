import 'package:entity_store/entity_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'entity.dart';

void main() {
  late EntityStoreController controller;
  late UserRepository repo;

  setUpAll(() {});
  setUp(() {
    controller = EntityStoreController(Store());
    repo = UserRepository(controller);
  });

  test('test_test', () {
    expect(1, 1);
  });

  test("findById", () async {
    await repo.save(users[0]);
    final userGet = await repo.findById(users[0].id);

    expect(userGet.success!.id, users[0].id);
    expect(
      controller.getById<UserId, User>(userGet.success!.id)!.id,
      users[0].id,
    );

    /// FindByIdOptions.fetchPolicy = FetchPolicy.storeOnly
    controller.put(users[1]);
    final userGet2 = await repo.findById(
      users[1].id,
      options: EntityStoreFindByIdOptions(fetchPolicy: FetchPolicy.storeOnly),
    );
    expect(userGet2.success!.id, users[1].id);

    final userGet3 = await repo.findById(
      users[2].id,
      options: EntityStoreFindByIdOptions(fetchPolicy: FetchPolicy.storeOnly),
    );
    expect(userGet3.success, null);

    /// FindByIdOptions.fetchPolicy = FetchPolicy.storeFirst
    final userGet4 = await repo.findById(
      users[1].id,
      options: EntityStoreFindByIdOptions(fetchPolicy: FetchPolicy.storeFirst),
    );
    expect(userGet4.success!.id, users[1].id);

    await repo.save(users[2]);
    controller.delete<UserId, User>(users[2].id);

    final userGet5 = await repo.findById(
      users[2].id,
      options: EntityStoreFindByIdOptions(fetchPolicy: FetchPolicy.storeFirst),
    );
    expect(userGet5.success!.id, users[2].id);
  });

  test("delete", () async {
    await repo.save(users.first);
    await repo.deleteById(users.first.id);
    final userGet = await repo.findById(users.first.id);

    expect(userGet.success, null);
    expect(controller.getById<UserId, User>(users.first.id), null);
  });

  test("findAll", () async {
    for (final user in users) {
      await repo.save(user);
    }

    final list = await repo.findAll();
    expect(list.success.length, users.length);
    expect(controller.where<UserId, User>().length, users.length);

    final list2 = await repo.query().limit(3).findAll();
    expect(list2.success.length, 3);

    final list3 = await repo.query().where('id', isEqualTo: '5').findAll();
    expect(list3.success.first.id.value, "5");

    /// FindAllOptions.fetchPolicy = FetchPolicy.storeOnly
    controller.delete<UserId, User>(users[0].id);
    final list4 = await repo.query().where('id', isEqualTo: '1').findAll(
          options:
              EntityStoreFindAllOptions(fetchPolicy: FetchPolicy.storeOnly),
        );
    expect(list4.success.length, 0);

    /// EntityStoreFindAllOptions.fetchPolicy = FetchPolicy.storeFirst
    final list5 = await repo.query().where('id', isEqualTo: '1').findAll(
          options:
              EntityStoreFindAllOptions(fetchPolicy: FetchPolicy.storeFirst),
        );
    expect(list5.success.length, 1);

    await repo.save(users[0]);
    controller.delete<UserId, User>(users[0].id);
    final list6 = await repo.query().where('id', isEqualTo: '1').findAll(
          options:
              EntityStoreFindAllOptions(fetchPolicy: FetchPolicy.storeFirst),
        );
    expect(list6.success.length, 1);

    await repo.save(users[0]);
    controller.delete<UserId, User>(users[0].id);
    final list7 = await repo.query().where('age', isEqualTo: 1).findAll(
          options:
              EntityStoreFindAllOptions(fetchPolicy: FetchPolicy.storeFirst),
        );
    expect(list7.success.length, 2);

    final list8 = await repo.query().where('age', isEqualTo: 1).findAll(
          options:
              EntityStoreFindAllOptions(fetchPolicy: FetchPolicy.persistent),
        );
    expect(list8.success.length, 3);
  });

  test("count", () async {
    for (final user in users) {
      await repo.save(user);
    }

    final count = await repo.count();
    expect(count.success, users.length);
  });

  test('upsert', () async {
    for (final user in users) {
      await repo.save(user);
    }

    final user = User(id: UserId("1"), name: "aaa", age: 1);
    final user2 = User(id: UserId("1"), name: "bbb", age: 2);

    // updated user because user is already exists
    await repo.upsert(
      user.id,
      creater: () => user,
      updater: (prev) => user2,
    );

    final userGet = await repo.findById(user.id);
    expect(userGet.success!.name, "bbb");

    // created new user because user is not exists
    final user3 = User(id: UserId("11"), name: "aaa", age: 1);
    await repo.upsert(
      user3.id,
      creater: () => user3,
      updater: (prev) => user2,
    );

    final userGet2 = await repo.findById(UserId("11"));
    expect(userGet2.success!.name, "aaa");
  });

  test("FetchPolicy", () async {
    final user = User(id: UserId("1"), name: "test", age: 20);

    // まずデータを保存
    await repo.save(user);

    // Storeからデータを削除
    controller.delete<UserId, User>(user.id);

    // FetchPolicy.storeOnly - Storeにないので null が返される
    final storeOnlyResult = await repo.findById(
      user.id,
      options: EntityStoreFindByIdOptions(fetchPolicy: FetchPolicy.storeOnly),
    );
    expect(storeOnlyResult.success, null);

    // FetchPolicy.storeFirst - Storeにないので永続化層から取得
    final storeFirstResult = await repo.findById(
      user.id,
      options: EntityStoreFindByIdOptions(fetchPolicy: FetchPolicy.storeFirst),
    );
    expect(storeFirstResult.success?.id, user.id);

    // Storeにデータを追加
    final updatedUser = User(id: UserId("1"), name: "updated", age: 30);
    controller.put(updatedUser);

    // FetchPolicy.storeFirst - Storeにあるのでそれを返す
    final storeFirstWithCacheResult = await repo.findById(
      user.id,
      options: EntityStoreFindByIdOptions(fetchPolicy: FetchPolicy.storeFirst),
    );
    expect(storeFirstWithCacheResult.success?.name, "updated");

    // FetchPolicy.persistent - 永続化層から必ず取得
    final persistentResult = await repo.findById(
      user.id,
      options: EntityStoreFindByIdOptions(fetchPolicy: FetchPolicy.persistent),
    );
    expect(persistentResult.success?.name, "test"); // 永続化層の元のデータ
  });

  test("FetchPolicy - findById", () async {
    final user = User(id: UserId("1"), name: "test", age: 20);

    // まずデータを保存
    await repo.save(user);

    // Storeからデータを削除
    controller.delete<UserId, User>(user.id);

    // FetchPolicy.storeOnly - Storeにないので null が返される
    final storeOnlyResult = await repo.findById(
      user.id,
      options: EntityStoreFindByIdOptions(fetchPolicy: FetchPolicy.storeOnly),
    );
    expect(storeOnlyResult.success, null);

    // FetchPolicy.storeFirst - Storeにないので永続化層から取得
    final storeFirstResult = await repo.findById(
      user.id,
      options: EntityStoreFindByIdOptions(fetchPolicy: FetchPolicy.storeFirst),
    );
    expect(storeFirstResult.success?.id, user.id);

    // Storeにデータを追加
    final updatedUser = User(id: UserId("1"), name: "updated", age: 30);
    controller.put(updatedUser);

    // FetchPolicy.storeFirst - Storeにあるのでそれを返す
    final storeFirstWithCacheResult = await repo.findById(
      user.id,
      options: EntityStoreFindByIdOptions(fetchPolicy: FetchPolicy.storeFirst),
    );
    expect(storeFirstWithCacheResult.success?.name, "updated");

    // FetchPolicy.persistent - 永続化層から必ず取得
    final persistentResult = await repo.findById(
      user.id,
      options: EntityStoreFindByIdOptions(fetchPolicy: FetchPolicy.persistent),
    );
    expect(persistentResult.success?.name, "test");
  });

  test("FetchPolicy - findAll", () async {
    final users = [
      User(id: UserId("1"), name: "test1", age: 20),
      User(id: UserId("2"), name: "test2", age: 20),
    ];

    // まずデータを保存
    for (final user in users) {
      await repo.save(user);
    }

    // Storeからデータを削除
    for (final user in users) {
      controller.delete<UserId, User>(user.id);
    }

    // FetchPolicy.storeOnly - Storeにないので空のリストが返される
    final storeOnlyResult = await repo.findAll(
      options: EntityStoreFindAllOptions(fetchPolicy: FetchPolicy.storeOnly),
    );
    expect(storeOnlyResult.success, isEmpty);

    // FetchPolicy.storeFirst - Storeにないので永続化層から取得
    final storeFirstResult = await repo.findAll(
      options: EntityStoreFindAllOptions(fetchPolicy: FetchPolicy.storeFirst),
    );
    expect(storeFirstResult.success.length, 2);

    // Storeにデータを追加（一部のデータを更新）
    final updatedUser = User(id: UserId("1"), name: "updated", age: 30);
    controller.put(updatedUser);

    // FetchPolicy.storeFirst - Storeにあるものを返す
    final storeFirstWithCacheResult = await repo.findAll(
      options: EntityStoreFindAllOptions(fetchPolicy: FetchPolicy.storeFirst),
    );
    expect(storeFirstWithCacheResult.success.length, 2);
    expect(storeFirstWithCacheResult.success.first.name, "updated");

    // FetchPolicy.persistent - 永続化層から必ず取得
    final persistentResult = await repo.findAll(
      options: EntityStoreFindAllOptions(fetchPolicy: FetchPolicy.persistent),
    );
    expect(persistentResult.success.length, 2);
    expect(persistentResult.success.first.name, "test1");
  });

  test("FetchPolicy - findOne", () async {
    final users = [
      User(id: UserId("1"), name: "test1", age: 20),
      User(id: UserId("2"), name: "test2", age: 20),
    ];

    // まずデータを保存
    for (final user in users) {
      await repo.save(user);
    }

    // Storeからデータを削除
    for (final user in users) {
      controller.delete<UserId, User>(user.id);
    }

    // FetchPolicy.storeOnly - Storeにないのでnullが返される
    final storeOnlyResult = await repo.findOne(
      options: EntityStoreFindOneOptions(fetchPolicy: FetchPolicy.storeOnly),
    );
    expect(storeOnlyResult.success, null);

    // FetchPolicy.storeFirst - Storeにないので永続化層から取得
    final storeFirstResult = await repo.findOne(
      options: EntityStoreFindOneOptions(fetchPolicy: FetchPolicy.storeFirst),
    );
    expect(storeFirstResult.success?.id, users.first.id);

    // Storeにデータを追加（一部のデータを更新）
    final updatedUser = User(id: UserId("1"), name: "updated", age: 30);
    controller.put(updatedUser);

    // FetchPolicy.storeFirst - Storeにあるものを返す
    final storeFirstWithCacheResult = await repo.findOne(
      options: EntityStoreFindOneOptions(fetchPolicy: FetchPolicy.storeFirst),
    );
    expect(storeFirstWithCacheResult.success?.name, "updated");

    // FetchPolicy.persistent - 永続化層から必ず取得
    final persistentResult = await repo.findOne(
      options: EntityStoreFindOneOptions(fetchPolicy: FetchPolicy.persistent),
    );
    expect(persistentResult.success?.name, "test1");
  });
}

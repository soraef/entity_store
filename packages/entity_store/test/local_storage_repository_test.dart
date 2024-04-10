import 'package:entity_store/entity_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'entity.dart';

class UserRepository extends LocalStorageRepository<UserId, User> {
  UserRepository(EntityStoreController controller)
      : super(
          controller,
          InMemoryStorageHandler(),
        );

  @override
  User fromJson(Map<String, dynamic> json) {
    return userConverter.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(User entity) {
    return userConverter.toJson(entity);
  }
}

void main() {
  late EntityStoreController controller;
  late UserRepository repo;

  setUpAll(() {});
  setUp(() {
    controller = EntityStoreController(Store());
    repo = UserRepository(controller);
  });

  test("get", () async {
    await repo.save(users.first);
    final userGet = await repo.findById(users.first.id);

    expect(userGet.ok!.id, users.first.id);
    expect(
      controller.getById<UserId, User>(userGet.ok!.id)!.id,
      users.first.id,
    );
  });

  test("delete", () async {
    await repo.save(users.first);
    await repo.delete(users.first.id);
    final userGet = await repo.findById(users.first.id);

    expect(userGet.ok, null);
    expect(controller.getById<UserId, User>(users.first.id), null);
  });

  test("list", () async {
    for (final user in users) {
      await repo.save(user);
    }

    final list = await repo.findAll();
    expect(list.ok.length, users.length);
    expect(controller.where<UserId, User>().length, users.length);

    final list2 = await repo.query().limit(3).findAll();
    expect(list2.ok.length, 3);

    final list3 = await repo.query().where('id', isEqualTo: '5').findAll();
    expect(list3.ok.first.id.value, "5");
  });

  test("count", () async {
    for (final user in users) {
      await repo.save(user);
    }

    final count = await repo.count();
    expect(count.ok, users.length);
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
    expect(userGet.ok!.name, "bbb");

    // created new user because user is not exists
    final user3 = User(id: UserId("11"), name: "aaa", age: 1);
    await repo.upsert(
      user3.id,
      creater: () => user3,
      updater: (prev) => user2,
    );

    final userGet2 = await repo.findById(UserId("11"));
    expect(userGet2.ok!.name, "aaa");
  });
}

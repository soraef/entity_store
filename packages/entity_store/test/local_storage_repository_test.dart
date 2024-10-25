import 'package:entity_store/entity_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'entity.dart';

class UserRepository extends LocalStorageRepository<User> {
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

  test("findById", () async {
    await repo.save(users[0]);
    final userGet = await repo.findById(users[0].id);

    expect(userGet.ok!.id, users[0].id);
    expect(
      controller.getById<User>(userGet.ok!.id)!.id,
      users[0].id,
    );

    /// FindByIdOptions.fetchPolicy = FetchPolicy.storeOnly
    controller.put(users[1]);
    final userGet2 = await repo.findById(
      users[1].id,
      options: const FindByIdOptions(fetchPolicy: FetchPolicy.storeOnly),
    );
    expect(userGet2.ok!.id, users[1].id);

    final userGet3 = await repo.findById(
      users[2].id,
      options: const FindByIdOptions(fetchPolicy: FetchPolicy.storeOnly),
    );
    expect(userGet3.ok, null);

    /// FindByIdOptions.fetchPolicy = FetchPolicy.storeFirst
    final userGet4 = await repo.findById(
      users[1].id,
      options: const FindByIdOptions(fetchPolicy: FetchPolicy.storeFirst),
    );
    expect(userGet4.ok!.id, users[1].id);

    await repo.save(users[2]);
    controller.delete<User>(users[2].id);

    final userGet5 = await repo.findById(
      users[2].id,
      options: const FindByIdOptions(fetchPolicy: FetchPolicy.storeFirst),
    );
    expect(userGet5.ok!.id, users[2].id);
  });

  test("delete", () async {
    await repo.save(users.first);
    await repo.delete(users.first.id);
    final userGet = await repo.findById(users.first.id);

    expect(userGet.ok, null);
    expect(controller.getById<User>(users.first.id), null);
  });

  test("findAll", () async {
    for (final user in users) {
      await repo.save(user);
    }

    final list = await repo.findAll();
    expect(list.ok.length, users.length);
    expect(controller.where<User>().length, users.length);

    final list2 = await repo.query().limit(3).findAll();
    expect(list2.ok.length, 3);

    final list3 = await repo.query().where('id', isEqualTo: '5').findAll();
    expect(list3.ok.first.id, "5");

    /// FindAllOptions.fetchPolicy = FetchPolicy.storeOnly
    controller.delete<User>(users[0].id);
    final list4 = await repo.query().where('id', isEqualTo: '1').findAll(
          options: const FindAllOptions(fetchPolicy: FetchPolicy.storeOnly),
        );
    expect(list4.ok.length, 0);

    /// FindAllOptions.fetchPolicy = FetchPolicy.storeFirst
    final list5 = await repo.query().where('id', isEqualTo: '1').findAll(
          options: const FindAllOptions(fetchPolicy: FetchPolicy.storeFirst),
        );
    expect(list5.ok.length, 1);

    await repo.save(users[0]);
    controller.delete<User>(users[0].id);
    final list6 = await repo.query().where('id', isEqualTo: '1').findAll(
          options: const FindAllOptions(fetchPolicy: FetchPolicy.storeFirst),
        );
    expect(list6.ok.length, 1);

    await repo.save(users[0]);
    controller.delete<User>(users[0].id);
    final list7 = await repo.query().where('age', isEqualTo: 1).findAll(
          options: const FindAllOptions(fetchPolicy: FetchPolicy.storeFirst),
        );
    expect(list7.ok.length, 2);

    final list8 = await repo.query().where('age', isEqualTo: 1).findAll(
          options: const FindAllOptions(fetchPolicy: FetchPolicy.persistent),
        );
    expect(list8.ok.length, 3);
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

    final user = User(id: "1", name: "aaa", age: 1);
    final user2 = User(id: "1", name: "bbb", age: 2);

    // updated user because user is already exists
    await repo.upsert(
      user.id,
      creater: () => user,
      updater: (prev) => user2,
    );

    final userGet = await repo.findById(user.id);
    expect(userGet.ok!.name, "bbb");

    // created new user because user is not exists
    final user3 = User(id: "11", name: "aaa", age: 1);
    await repo.upsert(
      user3.id,
      creater: () => user3,
      updater: (prev) => user2,
    );

    final userGet2 = await repo.findById(user3.id);
    expect(userGet2.ok!.name, "aaa");
  });
}

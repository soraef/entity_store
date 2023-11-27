import 'package:entity_store/entity_store.dart';
import 'package:entity_store/local_storage_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'entity.dart';

void main() {
  late EntityStoreController controller;
  late LocalStorageRepository<UserId, User> repo;

  setUp(() {
    controller = EntityStoreController(Store());
    repo = UserRepo(controller, InMemoryLocalStorageHandler());
  });

  test("findById", () async {
    await repo.save(users.first);
    final userGet = await repo.findById(users.first.id);

    expect(userGet.ok!.id, users.first.id);
    expect(
        controller.getById<UserId, User>(userGet.ok!.id)!.id, users.first.id);
  });

  test("delete", () async {
    await repo.save(users.first);
    await repo.delete(users.first.id);
    final userGet = await repo.findById(users.first.id);

    expect(userGet.okOrNull, null);
    expect(controller.getById<UserId, User>(users.first.id), null);
  });

  test("query", () async {
    for (final user in users) {
      await repo.save(user);
    }

    final list = await repo.query().findAll();
    expect(list.ok.length, users.length);
    expect(controller.where<UserId, User>().length, users.length);

    final list2 = await repo.query().limit(3).findAll();
    expect(list2.ok.length, 3);

    final list3 = await repo.query().where("id", isEqualTo: "5").findAll();
    expect(list3.ok.first.id.value, "5");
  });
}

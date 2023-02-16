import 'package:entity_store/src/repository.dart';
import 'package:entity_store/src/store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'entity.dart';

void main() {
  late EntityStoreController controller;
  late InMemoryRepository<UserId, User> repo;

  setUpAll(() {});
  setUp(() {
    controller = EntityStoreController(Store());
    repo = InMemoryRepository(controller, userConverter);
  });

  test("get", () async {
    await repo.save(users.first);
    final userGet = await repo.get(users.first.id);

    expect(userGet.ok!.id, users.first.id);
    expect(controller.get<UserId, User>(userGet.ok!.id)!.id, users.first.id);
  });

  test("delete", () async {
    await repo.save(users.first);
    await repo.delete(users.first);
    final userGet = await repo.get(users.first.id);

    expect(userGet.ok, null);
    expect(controller.get<UserId, User>(users.first.id), null);
  });

  test("list", () async {
    for (final user in users) {
      await repo.save(user);
    }

    final list = await repo.list();
    expect(list.ok.length, users.length);
    expect(controller.where<UserId, User>().length, users.length);

    final list2 = await repo.list((query) => query.limit(3));
    expect(list2.ok.length, 3);

    final list3 = await repo.list(
      (query) => query.where("id", isEqualTo: "5"),
    );
    expect(list3.ok.first.id.value, "5");
  });
}

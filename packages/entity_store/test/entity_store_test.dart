// ignore_for_file: unnecessary_type_check

import 'package:entity_store/src/entity_store.dart';
import 'package:flutter_test/flutter_test.dart';

class User extends Entity {
  @override
  final String id;
  final String name;

  User({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }
}

class Group extends Entity {
  @override
  final String id;
  final List<String> memberUserIds;
  Group({
    required this.id,
    required this.memberUserIds,
  });

  List<User> members(EntityMap<User> users) =>
      users.byIds(memberUserIds).toList();

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "memberUserIds": memberUserIds,
    };
  }
}

class Source with EntityStoreMixin {
  EntityStore state = EntityStore.empty();

  @override
  void update(Updater<EntityStore> updater) {
    state = updater(state);
  }

  @override
  EntityStore get value => state;
}

void main() {
  test("a", () {
    final event = GetEvent<User>.now('1', User(id: "1", name: "soraef"));
    expect(event is PersistenceEvent<User>, true);
    expect(event is PersistenceEvent<Group>, false);
  });

  test("b", () async {
    final source = Source();
    final controller = EntityStoreController(source);
    final event = GetEvent<User>.now(
      '1',
      User(id: "1", name: "soraef"),
    );
    final event2 = GetEvent<Group>.now(
      "1",
      Group(id: "1", memberUserIds: []),
    );
    controller.dispatch(event);
    controller.dispatch(event2);
    await Future.delayed(const Duration(milliseconds: 200));

    final event3 = GetEvent<User>.now(
      '1',
      User(id: "1", name: "changed"),
    );
    controller.dispatch(event3);
    await Future.delayed(const Duration(milliseconds: 100));
  });

  test("entity map", () {
    final user = User(id: "1", name: "soraef");
    final group = Group(id: "1", memberUserIds: ["1"]);
    final map = const EntityMap<User>({}).put(user);
    final map2 = const EntityMap<User>({}).put(user);

    expect(map == map2, true);

    var entityStore = EntityStore.empty();
    entityStore = entityStore.put(user);
    final map3 = entityStore.where();
    entityStore.put(group);
    final map4 = entityStore.where();
    expect(map3 == map4, true);
  });
}

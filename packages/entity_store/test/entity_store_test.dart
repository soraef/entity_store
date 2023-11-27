// ignore_for_file: unnecessary_type_check

import 'package:entity_store/store.dart';
import 'package:flutter_test/flutter_test.dart';

class User extends Entity<String> {
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

class Group extends Entity<String> {
  @override
  final String id;
  final List<String> memberUserIds;
  Group({
    required this.id,
    required this.memberUserIds,
  });

  List<User> members(EntityMap<String, User> users) =>
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
    final event =
        GetEvent<String, User>.now("1", User(id: "1", name: "soraef"));
    expect(event is StoreEvent<String, User>, true);
    expect(event is StoreEvent<String, Group>, false);
  });

  test("b", () async {
    final source = Source();
    final controller = EntityStoreController(source);
    final event = GetEvent<String, User>.now(
      "1",
      User(id: "1", name: "soraef"),
    );
    final event2 = GetEvent<String, Group>.now(
      "1",
      Group(id: "1", memberUserIds: []),
    );
    controller.dispatch(event);
    controller.dispatch(event2);
    await Future.delayed(const Duration(milliseconds: 200));

    final event3 = GetEvent<String, User>.now(
      "1",
      User(id: "1", name: "changed"),
    );
    controller.dispatch(event3);
    await Future.delayed(const Duration(milliseconds: 100));
  });

  test("entity map", () {
    final user = User(id: "1", name: "soraef");
    final group = Group(id: "1", memberUserIds: ["1"]);
    final map = const EntityMap<String, User>({}).put(user);
    final map2 = const EntityMap<String, User>({}).put(user);

    expect(map == map2, true);

    var entityStore = EntityStore.empty();
    entityStore = entityStore.put<String, User>(user);
    final map3 = entityStore.where<String, User>();
    entityStore.put<String, Group>(group);
    final map4 = entityStore.where<String, User>();
    expect(map3 == map4, true);
  });
}

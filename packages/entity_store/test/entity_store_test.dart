// ignore_for_file: unnecessary_type_check

import 'package:entity_store/entity_store.dart';
import 'package:entity_store/src/entity_store_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

class User extends Entity<String> {
  @override
  final String id;
  final String name;

  User({
    required this.id,
    required this.name,
  });
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
}

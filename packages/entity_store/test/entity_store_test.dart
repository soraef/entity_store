// import 'package:entity_store/entity_store.dart';

// class MessageRoom extends Entity<String> {
//   @override
//   final String id;
//   MessageRoom({required this.id});
// }

// ignore_for_file: unnecessary_type_check

import 'package:entity_store/entity_store.dart';
import 'package:flutter_test/flutter_test.dart';

class User extends Entity<String> {
  @override
  final String id;

  User({
    required this.id,
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

class UserStore extends EntityStoreBase<String, User, EntityMap<String, User>>
    with EntityMapStoreMixin<String, User> {
  @override
  void update(Updater<EntityMap<String, User>> updater) {
    value = updater(value);
  }

  @override
  EntityMap<String, User> value = EntityMap<String, User>.empty();
}

class GroupStore
    extends EntityStoreBase<String, Group, EntityMap<String, Group>>
    with EntityMapStoreMixin<String, Group> {
  @override
  void update(Updater<EntityMap<String, Group>> updater) {
    value = updater(value);
  }

  @override
  EntityMap<String, Group> value = EntityMap<String, Group>.empty();
}

void main() {
  test("a", () {
    final event = GetEvent<String, User>.now("1", User(id: "1"));
    expect(event is StoreEvent<String, User>, true);
    expect(event is StoreEvent<String, Group>, false);
  });
}

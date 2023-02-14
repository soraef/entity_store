// import 'package:entity_store/entity_store.dart';

// class MessageRoom extends Entity<String> {
//   @override
//   final String id;
//   MessageRoom({required this.id});
// }

// ignore_for_file: unnecessary_type_check

import 'package:entity_store/entity_store.dart';
import 'package:entity_store/src/entity_map_container.dart';
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

class Source with SingleSourceStoreMixin {
  EntityMapContainer state = EntityMapContainer.empty();

  @override
  void update(Updater<EntityMapContainer> updater) {
    state = updater(state);
  }

  @override
  EntityMapContainer get value => state;
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
    final dispater = StoreEventDispatcher(source);
    final event = GetEvent<String, User>.now(
      "1",
      User(id: "1", name: "soraef"),
    );
    final event2 = GetEvent<String, Group>.now(
      "1",
      Group(id: "1", memberUserIds: []),
    );
    dispater.dispatch(event);
    dispater.dispatch(event2);
    await Future.delayed(const Duration(milliseconds: 200));
    print(source.state.where<String, User>().length);
    print(source.state.get<String, User>("1")?.name);

    final event3 = GetEvent<String, User>.now(
      "1",
      User(id: "1", name: "changed"),
    );
    dispater.dispatch(event3);
    await Future.delayed(const Duration(milliseconds: 100));
    print(source.state.where<String, User>().length);
    print(source.state.get<String, User>("1")?.name);
  });
}

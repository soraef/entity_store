// import 'package:entity_store/entity_store.dart';

// class MessageRoom extends Entity<String> {
//   @override
//   final String id;
//   MessageRoom({required this.id});
// }

// ignore_for_file: unnecessary_type_check

import 'package:entity_store/entity_store.dart';
import 'package:entity_store/src/store_event.dart';
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
  Group({required this.id});
}

void main() {
  test("a", () {
    final event = GetEvent<String, User>(entity: User(id: "1"));
    expect(event is StoreEvent<String, User>, true);
    expect(event is StoreEvent<String, Group>, false);
  });
}

import 'package:entity_store/src/entity_store.dart';
import 'package:flutter_test/flutter_test.dart';

class User extends Entity<String> {
  @override
  final String id;
  final String name;

  User({required this.id, required this.name});
}

void main() {
  late EntityMap<String, User> emptyMap;
  late User user1;
  late User user2;
  late User user3;

  setUp(() {
    emptyMap = EntityMap<String, User>.empty();
    user1 = User(id: '1', name: 'Alice');
    user2 = User(id: '2', name: 'Bob');
    user3 = User(id: '3', name: 'Charlie');
  });

  group('EntityMap creation', () {
    test('empty creates an empty map', () {
      expect(emptyMap.length, 0);
      expect(emptyMap.entities, isEmpty);
      expect(emptyMap.ids, isEmpty);
    });

    test('fromIterable creates map from entities', () {
      final map = EntityMap<String, User>.fromIterable([user1, user2]);
      expect(map.length, 2);
      expect(map.byId('1'), user1);
      expect(map.byId('2'), user2);
    });

    test('fromIterable deduplicates by id', () {
      final duplicate = User(id: '1', name: 'Alice2');
      final map = EntityMap<String, User>.fromIterable([user1, duplicate]);
      expect(map.length, 1);
      expect(map.byId('1')!.name, 'Alice2');
    });
  });

  group('EntityMap accessors', () {
    late EntityMap<String, User> map;

    setUp(() {
      map = EntityMap<String, User>.fromIterable([user1, user2, user3]);
    });

    test('exist returns true for existing id', () {
      expect(map.exist('1'), true);
      expect(map.exist('999'), false);
    });

    test('byId returns entity or null', () {
      expect(map.byId('1'), user1);
      expect(map.byId('999'), null);
    });

    test('at returns entity by index', () {
      expect(map.at(0), user1);
      expect(map.at(2), user3);
    });

    test('at throws on out of bounds', () {
      expect(() => map.at(10), throwsA(isA<RangeError>()));
    });

    test('atOrNull returns null on out of bounds', () {
      expect(map.atOrNull(0), user1);
      expect(map.atOrNull(10), null);
    });

    test('byIds returns subset', () {
      final subset = map.byIds(['1', '3']);
      expect(subset.length, 2);
      expect(subset.exist('1'), true);
      expect(subset.exist('3'), true);
      expect(subset.exist('2'), false);
    });

    test('byIds ignores non-existing ids', () {
      final subset = map.byIds(['1', '999']);
      expect(subset.length, 1);
    });

    test('toList returns all entities', () {
      final list = map.toList();
      expect(list.length, 3);
    });

    test('ids returns all keys', () {
      expect(map.ids.toList(), ['1', '2', '3']);
    });
  });

  group('EntityMap mutations (immutable)', () {
    test('put adds new entity', () {
      final map = emptyMap.put(user1);
      expect(map.length, 1);
      expect(emptyMap.length, 0); // original unchanged
    });

    test('put overwrites existing entity', () {
      final map = emptyMap.put(user1);
      final updated = User(id: '1', name: 'Updated');
      final map2 = map.put(updated);
      expect(map2.byId('1')!.name, 'Updated');
      expect(map.byId('1')!.name, 'Alice'); // original unchanged
    });

    test('putAll adds multiple entities', () {
      final map = emptyMap.putAll([user1, user2, user3]);
      expect(map.length, 3);
    });

    test('remove removes entity', () {
      final map = emptyMap.putAll([user1, user2]);
      final map2 = map.remove(user1);
      expect(map2.length, 1);
      expect(map2.exist('1'), false);
      expect(map.length, 2); // original unchanged
    });

    test('removeAll removes multiple entities', () {
      final map = emptyMap.putAll([user1, user2, user3]);
      final map2 = map.removeAll([user1, user3]);
      expect(map2.length, 1);
      expect(map2.byId('2'), user2);
    });

    test('removeWhere removes matching entities', () {
      final map = emptyMap.putAll([user1, user2, user3]);
      final map2 = map.removeWhere((e) => e.name.startsWith('A'));
      expect(map2.length, 2);
      expect(map2.exist('1'), false);
    });

    test('removeById removes by id', () {
      final map = emptyMap.putAll([user1, user2]);
      final map2 = map.removeById('1');
      expect(map2.length, 1);
      expect(map2.exist('1'), false);
    });

    test('removeById on non-existing id returns same content', () {
      final map = emptyMap.put(user1);
      final map2 = map.removeById('999');
      expect(map2.length, 1);
    });
  });

  group('EntityMap merge', () {
    test('merge combines two maps', () {
      final map1 = EntityMap<String, User>.fromIterable([user1]);
      final map2 = EntityMap<String, User>.fromIterable([user2, user3]);
      final merged = map1.merge(map2);
      expect(merged.length, 3);
    });

    test('merge overwrites with other values', () {
      final map1 = EntityMap<String, User>.fromIterable([user1]);
      final updated = User(id: '1', name: 'Updated');
      final map2 = EntityMap<String, User>.fromIterable([updated]);
      final merged = map1.merge(map2);
      expect(merged.byId('1')!.name, 'Updated');
    });

    // ignore: deprecated_member_use_from_same_package
    test('marge is deprecated alias for merge', () {
      final map1 = EntityMap<String, User>.fromIterable([user1]);
      final map2 = EntityMap<String, User>.fromIterable([user2]);
      // ignore: deprecated_member_use_from_same_package
      final merged = map1.marge(map2);
      expect(merged.length, 2);
    });
  });

  group('EntityMap where / map / sorted', () {
    test('where filters entities', () {
      final map = EntityMap<String, User>.fromIterable([user1, user2, user3]);
      final filtered = map.where((e) => e.name.contains('o'));
      expect(filtered.length, 1);
      expect(filtered.byId('2')!.name, 'Bob');
    });

    test('where returns empty for no match', () {
      final map = EntityMap<String, User>.fromIterable([user1]);
      final filtered = map.where((e) => e.name == 'Nobody');
      expect(filtered.length, 0);
    });

    test('map transforms entities', () {
      final map = EntityMap<String, User>.fromIterable([user1, user2]);
      final names = map.map((e) => e.name).toList();
      expect(names, ['Alice', 'Bob']);
    });

    test('sorted sorts entities', () {
      final map = EntityMap<String, User>.fromIterable([user3, user1, user2]);
      final sorted = map.sorted((a, b) => a.name.compareTo(b.name));
      expect(sorted.map((e) => e.name).toList(), ['Alice', 'Bob', 'Charlie']);
    });

    test('or combines two filter results', () {
      final map = EntityMap<String, User>.fromIterable([user1, user2, user3]);
      final result = map.or(
        (m) => m.where((e) => e.id == '1'),
        (m) => m.where((e) => e.id == '3'),
      );
      expect(result.length, 2);
      expect(result.exist('1'), true);
      expect(result.exist('3'), true);
    });
  });

  group('EntityMap events', () {
    test('eventWhenPut returns created for new entity', () {
      final event = emptyMap.eventWhenPut(user1);
      expect(event, isA<EntityCreatedEvent<String, User>>());
      expect(event.entity, user1);
    });

    test('eventWhenPut returns updated for existing entity', () {
      final map = emptyMap.put(user1);
      final updated = User(id: '1', name: 'Updated');
      final event = map.eventWhenPut(updated);
      expect(event, isA<EntityUpdatedEvent<String, User>>());
    });

    test('eventWhenPutAll returns events for all entities', () {
      final events = emptyMap.eventWhenPutAll([user1, user2]);
      expect(events.length, 2);
      expect(events.every((e) => e is EntityCreatedEvent), true);
    });

    test('eventWhenRemove returns delete event for existing', () {
      final map = emptyMap.put(user1);
      final event = map.eventWhenRemove('1');
      expect(event, isA<EntityDeletedEvent<String, User>>());
    });

    test('eventWhenRemove returns null for non-existing', () {
      final event = emptyMap.eventWhenRemove('999');
      expect(event, null);
    });
  });

  group('EntityMap equality', () {
    test('same entities are equal', () {
      final map1 = EntityMap<String, User>.fromIterable([user1, user2]);
      final map2 = EntityMap<String, User>.fromIterable([user1, user2]);
      expect(map1, map2);
    });

    test('different entities are not equal', () {
      final map1 = EntityMap<String, User>.fromIterable([user1]);
      final map2 = EntityMap<String, User>.fromIterable([user2]);
      expect(map1, isNot(map2));
    });
  });
}

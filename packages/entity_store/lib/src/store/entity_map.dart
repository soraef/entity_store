part of "../store.dart";

// Copyright 2023 Sora Fukui. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The [EntityMap] class holds multiple Entities and provides Immutable [Entity] collection operations.
///
/// Entity<Id> is a class with an id property of type Id.
/// [EntityMap] holds generic [Id]-[Entity] pairs.
///
/// [EntityMap] class internally holds [Entity] as Map<Id, Entity>,
/// so [Entity] does not allow duplicate [Id]
class EntityMap<Id, E extends Entity<Id>> {
  final Map<Id, E> _entities;

  const EntityMap(this._entities);

  /// Create an empty [EntityMap]
  factory EntityMap.empty() => EntityMap<Id, E>(const {});

  /// Creates an [EntityMap] from an Iterable<Entity>.
  factory EntityMap.fromIterable(Iterable<E> entities) {
    return EntityMap<Id, E>({for (final entity in entities) entity.id: entity});
  }

  /// Returns all Entities held by [this].
  Iterable<E> get entities => _entities.values;

  /// Returns all Entities List
  List<E> toList() => entities.toList();

  /// Returns all the Id's that [this] holds
  Iterable<Id> get ids => _entities.keys;

  /// Returns the number of Entities that [this] holds.
  int get length => entities.length;

  EntityMap<Id2, E2> cast<Id2, E2 extends Entity<Id2>>() {
    final list = toList().map((e) => e as E2);
    return EntityMap.fromIterable(list);
  }

  /// returns true if this has an [id]
  bool exist(Id id) => _entities[id] != null;

  /// Returns the [Entity] of the [id] that this holds
  E? byId(Id id) => _entities[id];

  /// Returns the [Entity] of the [index]
  E at(int index) => _entities.values.toList()[index];

  E? atOrNull(int index) {
    try {
      return _entities.values.toList()[index];
    } catch (e) {
      return null;
    }
  }

  /// Returns the [Entity] of [ids] held by this as a new [EntityMap].
  EntityMap<Id, E> byIds(Iterable<Id> ids) {
    return EntityMap.fromIterable(
      ids.where((id) => exist(id)).map((id) => byId(id)!),
    );
  }

  /// Returns a new [EntityMap] with additional [entity].
  /// If the [entity] already exists, it is overwritten.
  EntityMap<Id, E> put(E entity) {
    return EntityMap<Id, E>({..._entities, entity.id: entity});
  }

  /// Returns a new [EntityMap] with additional [entities].
  /// Existing [Entity] objects are overwritten.
  EntityMap<Id, E> putAll(Iterable<E> entities) {
    return EntityMap<Id, E>({
      ..._entities,
      for (final entity in entities) entity.id: entity,
    });
  }

  /// Returns a new [EntityMap] with the [entity] removed.
  EntityMap<Id, E> remove(E entity) {
    return EntityMap<Id, E>(
      {..._entities}..removeWhere((id, _) => id == entity.id),
    );
  }

  /// Returns a new [EntityMap] with the [entities] removed.
  EntityMap<Id, E> removeAll(Iterable<E> entities) {
    return EntityMap<Id, E>(
      {..._entities}..removeWhere(
          (id, entity) => entities.map((e) => e.id).contains(id),
        ),
    );
  }

  /// Returns a new [EntityMap] with all Entities removed that satisfy the given [test].
  EntityMap<Id, E> removeWhere(bool Function(E entity) test) {
    return EntityMap<Id, E>(
      {..._entities}..removeWhere((id, e) => test(e)),
    );
  }

  /// Returns a new [EntityMap] with the Entity with [id] removed.
  EntityMap<Id, E> removeById(Id id) {
    return EntityMap<Id, E>(
      {..._entities}..removeWhere((eid, entity) => id == eid),
    );
  }

  /// Returns a new [EntityMap] with [other] merged.
  EntityMap<Id, E> marge(EntityMap<Id, E> other) {
    return EntityMap<Id, E>({..._entities, ...other._entities});
  }

  /// Returns a new [EntityMap] that holds all Entities that satisfy the given [test].
  EntityMap<Id, E> where(bool Function(E) test) {
    return EntityMap.fromIterable(_entities.values.where(test));
  }

  EntityMap<Id, E> or(
    EntityMap<Id, E> Function(EntityMap<Id, E> entityMap) f1,
    EntityMap<Id, E> Function(EntityMap<Id, E> entityMap) f2,
  ) {
    return f1(this).marge(f2(this));
  }

  /// The current elements of this iterable modified by convert.
  Iterable<T> map<T>(T Function(E entity) convert) {
    return entities.map(convert);
  }

  /// Creates a sorted list of the elements of the iterable.
  ///
  /// The elements are ordered by the [compare] [Comparator].
  List<E> sorted(int Function(E a, E b) compare) {
    return entities.sorted(compare);
  }
}

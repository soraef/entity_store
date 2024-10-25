part of '../entity_store.dart';

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
class EntityMap<E extends Entity> extends Equatable {
  final Map<String, E> _entities;

  const EntityMap(this._entities);

  /// Create an empty [EntityMap]
  factory EntityMap.empty() => EntityMap<E>(const {});

  /// Creates an [EntityMap] from an Iterable<Entity>.
  factory EntityMap.fromIterable(Iterable<E> entities) {
    return EntityMap<E>({for (final entity in entities) entity.id: entity});
  }

  /// Returns all Entities held by [this].
  Iterable<E> get entities => _entities.values;

  /// Returns all Entities List
  List<E> toList() => entities.toList();

  /// Returns all the Id's that [this] holds
  Iterable<String> get ids => _entities.keys;

  /// Returns the number of Entities that [this] holds.
  int get length => entities.length;

  EntityMap<E2> cast<E2 extends Entity>() {
    final list = toList().map((e) => e as E2);
    return EntityMap.fromIterable(list);
  }

  /// returns true if this has an [id]
  bool exist(String id) => _entities[id] != null;

  /// Returns the [Entity] of the [id] that this holds
  E? byId(String id) => _entities[id];

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
  EntityMap<E> byIds(Iterable<String> ids) {
    return EntityMap.fromIterable(
      ids.where((id) => exist(id)).map((id) => byId(id)!),
    );
  }

  /// Returns a new [EntityMap] with additional [entity].
  /// If the [entity] already exists, it is overwritten.
  EntityMap<E> put(E entity) {
    return EntityMap<E>({..._entities, entity.id: entity});
  }

  /// Returns a new [EntityMap] with additional [entities].
  /// Existing [Entity] objects are overwritten.
  EntityMap<E> putAll(Iterable<E> entities) {
    return EntityMap<E>({
      ..._entities,
      for (final entity in entities) entity.id: entity,
    });
  }

  /// Returns a new [EntityMap] with the [entity] removed.
  EntityMap<E> remove(E entity) {
    return EntityMap<E>(
      {..._entities}..removeWhere((id, _) => id == entity.id),
    );
  }

  /// Returns a new [EntityMap] with the [entities] removed.
  EntityMap<E> removeAll(Iterable<E> entities) {
    return EntityMap<E>(
      {..._entities}..removeWhere(
          (id, entity) => entities.map((e) => e.id).contains(id),
        ),
    );
  }

  /// Returns a new [EntityMap] with all Entities removed that satisfy the given [test].
  EntityMap<E> removeWhere(bool Function(E entity) test) {
    return EntityMap<E>(
      {..._entities}..removeWhere((id, e) => test(e)),
    );
  }

  /// Returns a new [EntityMap] with the Entity with [id] removed.
  EntityMap<E> removeById(String id) {
    return EntityMap<E>(
      {..._entities}..removeWhere((eid, entity) => id == eid),
    );
  }

  /// Returns a new [EntityMap] with [other] merged.
  EntityMap<E> marge(EntityMap<E> other) {
    return EntityMap<E>({..._entities, ...other._entities});
  }

  /// Returns a new [EntityMap] that holds all Entities that satisfy the given [test].
  EntityMap<E> where(bool Function(E) test) {
    return EntityMap.fromIterable(_entities.values.where(test));
  }

  EntityMap<E> or(
    EntityMap<E> Function(EntityMap<E> entityMap) f1,
    EntityMap<E> Function(EntityMap<E> entityMap) f2,
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

  EntityEvent<E> eventWhenPut(E entity) {
    if (exist(entity.id)) {
      return EntityUpdatedEvent<E>(entity);
    } else {
      return EntityCreatedEvent<E>(entity);
    }
  }

  List<EntityEvent<E>> eventWhenPutAll(Iterable<E> entities) {
    return entities.map((e) => eventWhenPut(e)).toList();
  }

  EntityEvent<E>? eventWhenRemove(String id) {
    if (exist(id)) {
      return EntityDeletedEvent<E>(byId(id)!);
    } else {
      return null;
    }
  }

  @override
  List<Object?> get props => [...entities];
}

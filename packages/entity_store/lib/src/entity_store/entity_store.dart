part of '../entity_store.dart';

class EntityStore extends Equatable {
  final Map<Type, EntityMap<dynamic, dynamic>> _entityMaps;

  const EntityStore._(this._entityMaps);

  factory EntityStore.empty() {
    return const EntityStore._({});
  }

  EntityStore put<Id, E extends Entity<Id>>(E entity) {
    return EntityStore._({
      ..._entityMaps,
      E: _entityMaps[E]?.put(entity) ?? EntityMap<Id, E>.fromIterable([entity])
    });
  }

  EntityStore putAll<Id, E extends Entity<Id>>(Iterable<E> entities) {
    return EntityStore._({
      ..._entityMaps,
      E: _entityMaps[E]?.putAll(entities) ??
          EntityMap<Id, E>.fromIterable(entities),
    });
  }

  EntityStore delete<Id, E extends Entity<Id>>(Id id) {
    return EntityStore._({
      ..._entityMaps,
      E: _entityMaps[E]?.removeById(id) ?? EntityMap<Id, E>.empty()
    });
  }

  E? get<Id, E extends Entity<Id>>(Id id) {
    return _entityMaps[E]?.byId(id);
  }

  EntityMap<Id, E> where<Id, E extends Entity<Id>>([
    bool Function(E entity) test = testAlwaysTrue,
  ]) {
    return (getEntityMap<Id, E>() ?? EntityMap<Id, E>.empty()).where(test);
  }

  List<E> toList<E>() {
    return (_entityMaps[E]?.toList() ?? <E>[]) as List<E>;
  }

  EntityEvent<Id, E> eventWhenPut<Id, E extends Entity<Id>>(E entity) {
    return getEntityMap<Id, E>()?.eventWhenPut(entity) ??
        EntityCreatedEvent<Id, E>(entity);
  }

  List<EntityEvent<Id, E>> eventWhenPutAll<Id, E extends Entity<Id>>(
    Iterable<E> entities,
  ) {
    return getEntityMap<Id, E>()?.eventWhenPutAll(entities) ??
        entities.map((e) => EntityCreatedEvent<Id, E>(e)).toList();
  }

  EntityEvent? eventWhenDelete<Id, E extends Entity<Id>>(Id id) {
    return getEntityMap<Id, E>()?.eventWhenRemove(id);
  }

  EntityMap<Id, E>? getEntityMap<Id, E extends Entity<Id>>() {
    return _entityMaps[E] as EntityMap<Id, E>?;
  }

  @override
  String toString() {
    return _entityMaps.toString();
  }

  @override
  List<Object?> get props => [..._entityMaps.values];
}

bool testAlwaysTrue(dynamic param) => true;

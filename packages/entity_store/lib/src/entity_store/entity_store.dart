part of '../entity_store.dart';

class EntityStore extends Equatable {
  final Map<Type, EntityMap<dynamic>> _entityMaps;

  const EntityStore._(this._entityMaps);

  factory EntityStore.empty() {
    return const EntityStore._({});
  }

  EntityStore put<E extends Entity>(E entity) {
    return EntityStore._({
      ..._entityMaps,
      E: _entityMaps[E]?.put(entity) ?? EntityMap<E>.fromIterable([entity])
    });
  }

  EntityStore putAll<E extends Entity>(Iterable<E> entities) {
    return EntityStore._({
      ..._entityMaps,
      E: _entityMaps[E]?.putAll(entities) ??
          EntityMap<E>.fromIterable(entities),
    });
  }

  EntityStore delete<E extends Entity>(String id) {
    return EntityStore._({
      ..._entityMaps,
      E: _entityMaps[E]?.removeById(id) ?? EntityMap<E>.empty()
    });
  }

  E? get<E extends Entity>(String id) {
    return _entityMaps[E]?.byId(id);
  }

  EntityMap<E> where<E extends Entity>([
    bool Function(E entity) test = testAlwaysTrue,
  ]) {
    return (getEntityMap<E>() ?? EntityMap<E>.empty()).where(test);
  }

  List<E> toList<E>() {
    return (_entityMaps[E]?.toList() ?? <E>[]) as List<E>;
  }

  EntityEvent<E> eventWhenPut<E extends Entity>(E entity) {
    return getEntityMap<E>()?.eventWhenPut(entity) ??
        EntityCreatedEvent<E>(entity);
  }

  List<EntityEvent<E>> eventWhenPutAll<E extends Entity>(
    Iterable<E> entities,
  ) {
    return getEntityMap<E>()?.eventWhenPutAll(entities) ??
        entities.map((e) => EntityCreatedEvent<E>(e)).toList();
  }

  EntityEvent? eventWhenDelete<E extends Entity>(String id) {
    return getEntityMap<E>()?.eventWhenRemove(id);
  }

  EntityMap<E>? getEntityMap<E extends Entity>() {
    return _entityMaps[E] as EntityMap<E>?;
  }

  @override
  String toString() {
    return _entityMaps.toString();
  }

  @override
  List<Object?> get props => [..._entityMaps.values];
}

bool testAlwaysTrue(dynamic param) => true;

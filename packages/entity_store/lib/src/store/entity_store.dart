part of "../store.dart";

class EntityStore {
  final Map<Type, EntityMap<dynamic, dynamic>> _entityMaps;

  EntityStore._(this._entityMaps);

  factory EntityStore.empty() {
    return EntityStore._({});
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
    return (_entityMaps[E] as EntityMap<Id, E>? ?? EntityMap<Id, E>.empty())
        .where(test);
  }

  List<E> toList<E>() {
    return (_entityMaps[E]?.toList() ?? <E>[]) as List<E>;
  }

  @override
  String toString() {
    return _entityMaps.toString();
  }
}

bool testAlwaysTrue(dynamic param) => true;

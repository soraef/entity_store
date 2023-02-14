import 'entity.dart';
import 'entity_map.dart';

class EntityMapContainer {
  final Map<Type, EntityMap<dynamic, dynamic>> _entityMaps;

  EntityMapContainer(this._entityMaps);

  factory EntityMapContainer.empty() {
    return EntityMapContainer({});
  }

  EntityMapContainer put<Id, E extends Entity<Id>>(E entity) {
    return EntityMapContainer({
      ..._entityMaps,
      E: _entityMaps[E]?.put(entity) ?? EntityMap<Id, E>.fromIterable([entity])
    });
  }

  EntityMapContainer putAll<Id, E extends Entity<Id>>(Iterable<E> entities) {
    return EntityMapContainer({
      ..._entityMaps,
      E: _entityMaps[E]?.putAll(entities) ??
          EntityMap<Id, E>.fromIterable(entities),
    });
  }

  EntityMapContainer delete<Id, E extends Entity<Id>>(Id id) {
    return EntityMapContainer({
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

  @override
  String toString() {
    return _entityMaps.toString();
  }
}

bool testAlwaysTrue(dynamic param) => true;

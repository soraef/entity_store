import 'entity.dart';
import 'entity_map.dart';

typedef Updater<T> = T Function(T prev);

abstract class Store<T> {
  T get value;
  void update(Updater<T> updater);
}

mixin EntityStore<Id, E extends Entity<Id>> implements Store<EntityMap<Id, E>> {
  void put(E entity) {
    update((prev) => prev.put(entity));
  }

  void putAll(Iterable<E> entities) {
    update((prev) => prev.putAll(entities));
  }

  void remove(E entity) {
    update((prev) => prev.remove(entity));
  }

  void removeById(E entity) {
    update((prev) => prev.removeById(entity.id));
  }
}

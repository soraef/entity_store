import 'package:entity_store/entity_store.dart';

typedef Updater<T> = T Function(T prev);

abstract class StoreBase<T> {
  T get value;
  void update(Updater<T> updater);
  void handleEvent(StoreEvent event);
  bool shouldListenTo(StoreEvent event);
}

abstract class EntityStoreBase<Id, E extends Entity<Id>, T>
    extends StoreBase<T> {
  E? getById(Id id);
}

mixin EntityMapStoreMixin<Id, E extends Entity<Id>>
    on EntityStoreBase<Id, E, EntityMap<Id, E>> {
  @override
  E? getById(Id id) {
    return value.byId(id);
  }

  @override
  bool shouldListenTo(StoreEvent event) {
    return event is StoreEvent<Id, E>;
  }

  @override
  void handleEvent(covariant StoreEvent<Id, E> event) {
    if (event is GetEvent<Id, E>) {
      update(
        (prev) => event.entity != null
            ? prev.put(event.entity!)
            : prev.removeById(event.id),
      );
    } else if (event is ListEvent<Id, E>) {
      update((prev) => prev.putAll(event.entities));
    } else if (event is SaveEvent<Id, E>) {
      update((prev) => prev.put(event.entity));
    } else if (event is DeleteEvent<Id, E>) {
      update((prev) => prev.removeById(event.entityId));
    }
  }
}

mixin EntityStoreMixin<Id, E extends Entity<Id>> on EntityStoreBase<Id, E, E?> {
  @override
  E? getById(Id id) {
    return value?.id == id ? value : null;
  }

  @override
  bool shouldListenTo(StoreEvent event) {
    return event is StoreEvent<Id, E>;
  }

  @override
  void handleEvent(covariant StoreEvent<Id, E> event) {
    if (event is GetEvent<Id, E>) {
      update((prev) => event.entity);
    } else if (event is SaveEvent<Id, E>) {
      update((prev) => event.entity);
    } else if (event is DeleteEvent<Id, E>) {
      update((prev) => null);
    }
  }
}

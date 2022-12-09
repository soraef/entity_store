import 'package:entity_store/entity_store.dart';

import 'store_event.dart';

typedef Updater<T> = T Function(T prev);

abstract class IStore<T> {
  T get value;
  void update(Updater<T> updater);
  void handleEvent(StoreEvent event);
  bool shouldListenTo(StoreEvent event);
}

abstract class IEntityMapStore<Id, E extends Entity<Id>>
    extends IStore<EntityMap<Id, E>> {
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
            : prev.remove(event.entity!),
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

abstract class IEntityStore<Id, E extends Entity<Id>> extends IStore<E?> {
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

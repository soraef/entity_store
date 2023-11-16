part of "../store.dart";

class EntityStoreNotifier extends ChangeNotifier with EntityStoreMixin {
  EntityStore state = EntityStore.empty();

  @override
  void update(Updater<EntityStore> updater) {
    state = updater(state);
    notifyListeners();
  }

  @override
  EntityStore get value => state;
}

mixin EntityStoreMixin implements StoreEventHandler, Updatable<EntityStore> {
  @override
  void handleEvent<Id, E extends Entity<Id>>(
    StoreEvent<Id, E> event,
  ) {
    if (event is GetEvent<Id, E>) {
      update(
        (prev) => event.entity != null
            ? prev.put<Id, E>(event.entity!)
            : prev.delete<Id, E>(event.id),
      );
    } else if (event is ListEvent<Id, E>) {
      update((prev) => prev.putAll<Id, E>(event.entities));
    } else if (event is SaveEvent<Id, E>) {
      update((prev) => prev.put<Id, E>(event.entity));
    } else if (event is DeleteEvent<Id, E>) {
      update((prev) => prev.delete<Id, E>(event.entityId));
    }
  }

  @override
  bool shouldListenTo<Id, E extends Entity<Id>>(StoreEvent event) {
    return event is StoreEvent<Id, E>;
  }
}

typedef Updater<T> = T Function(T prev);

abstract class Updatable<T> {
  T get value;
  void update(Updater<T> updater);
}

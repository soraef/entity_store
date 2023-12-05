part of '../entity_store.dart';

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

mixin EntityStoreMixin
    implements IPersistenceEventHandler, IUpdatable<EntityStore> {
  final _entityEventController = StreamController<EntityEvent>.broadcast();

  Stream<EntityEvent> get entityEventStream => _entityEventController.stream;

  @override
  void handleEvent<Id, E extends Entity<Id>>(
    PersistenceEvent<Id, E> event,
  ) {
    if (event is GetEvent<Id, E>) {
      update((prev) {
        if (event.entity != null) {
          _entityEventController.add(prev.eventWhenPut<Id, E>(event.entity!));
          return prev.put<Id, E>(event.entity!);
        } else {
          final deleteEvent = prev.eventWhenDelete<Id, E>(event.id);
          if (deleteEvent != null) {
            _entityEventController.add(deleteEvent);
          }

          return prev.delete<Id, E>(event.id);
        }
      });
    } else if (event is ListEvent<Id, E>) {
      update((prev) {
        final entityEvents = prev.eventWhenPutAll<Id, E>(event.entities);
        entityEvents.forEach(_entityEventController.add);

        return prev.putAll<Id, E>(event.entities);
      });
    } else if (event is SaveEvent<Id, E>) {
      update((prev) {
        _entityEventController.add(prev.eventWhenPut<Id, E>(event.entity));
        return prev.put<Id, E>(event.entity);
      });
    } else if (event is DeleteEvent<Id, E>) {
      update((prev) {
        final deleteEvent = prev.eventWhenDelete<Id, E>(event.entityId);
        if (deleteEvent != null) {
          _entityEventController.add(deleteEvent);
        }
        return prev.delete<Id, E>(event.entityId);
      });
    }
  }

  @override
  bool shouldListenTo<Id, E extends Entity<Id>>(PersistenceEvent event) {
    return event is PersistenceEvent<Id, E>;
  }
}

typedef Updater<T> = T Function(T prev);

abstract class IUpdatable<T> {
  T get value;
  void update(Updater<T> updater);
}

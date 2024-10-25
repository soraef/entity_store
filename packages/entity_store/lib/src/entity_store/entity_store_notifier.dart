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
  void handleEvent<E extends Entity>(
    PersistenceEvent<E> event,
  ) {
    if (event is GetEvent<E>) {
      update((prev) {
        if (event.entity != null) {
          _entityEventController.add(prev.eventWhenPut<E>(event.entity!));
          return prev.put<E>(event.entity!);
        } else {
          final deleteEvent = prev.eventWhenDelete<E>(event.id);
          if (deleteEvent != null) {
            _entityEventController.add(deleteEvent);
          }

          return prev.delete<E>(event.id);
        }
      });
    } else if (event is ListEvent<E>) {
      update((prev) {
        final entityEvents = prev.eventWhenPutAll<E>(event.entities);
        entityEvents.forEach(_entityEventController.add);

        return prev.putAll<E>(event.entities);
      });
    } else if (event is SaveEvent<E>) {
      update((prev) {
        _entityEventController.add(prev.eventWhenPut<E>(event.entity));
        return prev.put<E>(event.entity);
      });
    } else if (event is DeleteEvent<E>) {
      update((prev) {
        final deleteEvent = prev.eventWhenDelete<E>(event.entityId);
        if (deleteEvent != null) {
          _entityEventController.add(deleteEvent);
        }
        return prev.delete<E>(event.entityId);
      });
    }
  }

  @override
  bool shouldListenTo<E extends Entity>(PersistenceEvent event) {
    return event is PersistenceEvent<E>;
  }
}

typedef Updater<T> = T Function(T prev);

abstract class IUpdatable<T> {
  T get value;
  void update(Updater<T> updater);
}

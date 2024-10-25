part of '../entity_store.dart';

class EntityStoreController {
  final _controller = StreamController<PersistenceEvent>.broadcast();
  final EntityStoreMixin _entityStore;
  final List<EntityEventListener> _listeners = [];
  late final StreamSubscription<EntityEvent> entityEventSubscription;

  Stream<PersistenceEvent> get eventStream => _controller.stream;
  Stream<EntityEvent> get entityEventStream => _entityStore.entityEventStream;

  EntityStoreController(this._entityStore) {
    _listenToEntityEvent();
  }

  void dispatch<E extends Entity>(PersistenceEvent<E> event) {
    event.apply(_entityStore);
    _controller.sink.add(event);
  }

  void clearAll() {
    _entityStore.update((prev) => EntityStore.empty());
  }

  void put<E extends Entity>(E entity) {
    _entityStore.update((prev) => prev.put<E>(entity));
  }

  void delete<E extends Entity>(String id) {
    _entityStore.update((prev) => prev.delete<E>(id));
  }

  void registEntityEventListener(EntityEventListener listener) {
    listener.setController(this);
    _listeners.add(listener);
  }

  E? getById<E extends Entity>(String id) {
    return _entityStore.value.get<E>(id);
  }

  List<E> getAll<E extends Entity>() {
    return _entityStore.value.getEntityMap<E>()?.entities.toList() ?? [];
  }

  EntityMap<E> where<E extends Entity>([
    bool Function(E) test = testAlwaysTrue,
  ]) {
    return _entityStore.value.where(test);
  }

  void _listenToEntityEvent<E extends Entity>() {
    entityEventSubscription = entityEventStream.listen((event) {
      for (var listener in _listeners) {
        if (listener.shouldListenTo(event)) {
          listener.handleEvent(event);
        }
      }
    });
  }
}

class StoreEventCache {
  final Map<Type, List<PersistenceEvent>> _cache = {};

  Future<void> put(PersistenceEvent event) async {
    _cache[event.entityType] ??= [];
    _cache[event.entityType]!.add(event);
  }

  Future<void> clear<E extends Entity>() async {
    _cache[E] = [];
  }

  Future<void> clearAll() async {
    _cache.clear();
  }

  Future<List<PersistenceEvent>> getEvents<E extends Entity>() async {
    return _cache[E] ?? [];
  }
}

mixin EntityChangeNotifier<E extends Entity> {
  EntityStoreController get controller;

  void notifyGetComplete(E entity) {
    controller.dispatch(GetEvent<E>.now(entity.id, entity));
  }

  void notifyEntityNotFound(String id) {
    controller.dispatch(GetEvent<E>.now(id, null));
  }

  void notifyListComplete(List<E> entities) {
    controller.dispatch(ListEvent<E>.now(entities));
  }

  void notifySaveComplete(E entity) {
    controller.dispatch(SaveEvent<E>.now(entity));
  }

  void notifyDeleteComplete(String id) {
    controller.dispatch(DeleteEvent<E>.now(id));
  }
}

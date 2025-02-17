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

  factory EntityStoreController.empty() {
    return _EmptyEntityStoreController();
  }

  void dispatch<Id, E extends Entity<Id>>(PersistenceEvent<Id, E> event) {
    event.apply(_entityStore);
    _controller.sink.add(event);
  }

  void clearAll() {
    _entityStore.update((prev) => EntityStore.empty());
  }

  void put<Id, E extends Entity<Id>>(E entity) {
    _entityStore.update((prev) => prev.put<Id, E>(entity));
  }

  void delete<Id, E extends Entity<Id>>(Id id) {
    _entityStore.update((prev) => prev.delete<Id, E>(id));
  }

  void registEntityEventListener(EntityEventListener listener) {
    listener.setController(this);
    _listeners.add(listener);
  }

  E? getById<Id, E extends Entity<Id>>(Id id) {
    return _entityStore.value.get<Id, E>(id);
  }

  List<E> getAll<Id, E extends Entity<Id>>() {
    return _entityStore.value.getEntityMap<Id, E>()?.entities.toList() ?? [];
  }

  EntityMap<Id, E> where<Id, E extends Entity<Id>>([
    bool Function(E) test = testAlwaysTrue,
  ]) {
    return _entityStore.value.where(test);
  }

  void _listenToEntityEvent<Id, E extends Entity<Id>>() {
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

  Future<void> clear<Id, E extends Entity<Id>>() async {
    _cache[E] = [];
  }

  Future<void> clearAll() async {
    _cache.clear();
  }

  Future<List<PersistenceEvent>> getEvents<Id, E extends Entity<Id>>() async {
    return _cache[E] ?? [];
  }
}

mixin EntityChangeNotifier<Id, E extends Entity<Id>> {
  EntityStoreController get controller;

  void notifyGetComplete(E entity) {
    controller.dispatch(GetEvent<Id, E>.now(entity.id, entity));
  }

  void notifyEntityNotFound(Id id) {
    controller.dispatch(GetEvent<Id, E>.now(id, null));
  }

  void notifyListComplete(List<E> entities) {
    controller.dispatch(ListEvent<Id, E>.now(entities));
  }

  void notifySaveComplete(E entity) {
    controller.dispatch(SaveEvent<Id, E>.now(entity));
  }

  void notifyDeleteComplete(Id id) {
    controller.dispatch(DeleteEvent<Id, E>.now(id));
  }
}

class _EmptyEntityStoreController extends EntityStoreController {
  _EmptyEntityStoreController() : super(_EmptyEntityStoreNotifier());
}

class _EmptyEntityStoreNotifier with EntityStoreMixin {
  @override
  void update(Updater<EntityStore> updater) {}

  @override
  EntityStore get value => EntityStore.empty();
}

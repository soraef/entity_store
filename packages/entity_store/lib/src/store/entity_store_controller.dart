part of '../../store.dart';

class EntityStoreController {
  final _controller = StreamController<StoreEvent>.broadcast();
  final EntityStoreMixin _entityStore;

  Stream<StoreEvent> get eventStream => _controller.stream;

  EntityStoreController(this._entityStore);

  void dispatch<Id, E extends Entity<Id>>(StoreEvent<Id, E> event) {
    event.apply(_entityStore);
    _controller.sink.add(event);
  }

  void clearAll() {
    _entityStore.update((prev) => EntityStore.empty());
  }

  E? getById<Id, E extends Entity<Id>>(Id id) {
    return _entityStore.value.get<Id, E>(id);
  }

  EntityMap<Id, E> where<Id, E extends Entity<Id>>([
    bool Function(E) test = testAlwaysTrue,
  ]) {
    return _entityStore.value.where(test);
  }
}

class StoreEventCache {
  final Map<Type, List<StoreEvent>> _cache = {};

  Future<void> put(StoreEvent event) async {
    _cache[event.entityType] ??= [];
    _cache[event.entityType]!.add(event);
  }

  Future<void> clear<Id, E extends Entity<Id>>() async {
    _cache[E] = [];
  }

  Future<void> clearAll() async {
    _cache.clear();
  }

  Future<List<StoreEvent>> getEvents<Id, E extends Entity<Id>>() async {
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

import 'dart:async';

import 'package:entity_store/entity_store.dart';

class StoreEventDispatcher {
  final _controller = StreamController<StoreEvent>.broadcast();
  final Set<StoreBase> _stores = {};

  Stream<StoreEvent> get eventStream => _controller.stream;

  StoreEventDispatcher() {
    _controller.stream.listen((event) {
      for (var store in _stores) {
        if (store.shouldListenTo(event)) {
          store.handleEvent(event);
        }
      }
    });
  }

  void register(StoreBase store) {
    _stores.add(store);
  }

  void unregister(StoreBase store) {
    _stores.remove(store);
  }

  void dispatch(StoreEvent event) {
    _controller.sink.add(event);
  }

  E? getEntityFromStore<Id, E extends Entity<Id>>(Id id) {
    for (var store in _stores) {
      if (store is EntityStoreBase<Id, E, dynamic>) {
        return store.getById(id);
      }
    }
    return null;
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

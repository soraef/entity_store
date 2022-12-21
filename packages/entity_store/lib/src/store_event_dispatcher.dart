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

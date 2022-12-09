import 'dart:async';

import 'package:entity_store/entity_store.dart';
import 'package:entity_store/src/store_event.dart';

class StoreEventDispatcher {
  final _controller = StreamController<StoreEvent>.broadcast();
  final Set<IStore> _stores = {};

  StoreEventDispatcher() {
    _controller.stream.listen((event) {
      for (var store in _stores) {
        if (store.shouldListenTo(event)) {
          store.handleEvent(event);
        }
      }
    });
  }

  void register(IStore store) {
    _stores.add(store);
  }

  void unregister(IStore store) {
    _stores.remove(store);
  }

  void dispatch(StoreEvent event) {
    _controller.sink.add(event);
  }
}

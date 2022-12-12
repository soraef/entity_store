import 'dart:async';

import 'package:entity_store/entity_store.dart';

class StoreEventDispatcher {
  final _controller = StreamController<StoreEvent>.broadcast();
  final Set<IStore> _stores = {};
  final bool debugPrint;

  StoreEventDispatcher({this.debugPrint = false}) {
    _controller.stream.listen((event) {
      if (debugPrint) {
        event.debugPrint();
      }
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

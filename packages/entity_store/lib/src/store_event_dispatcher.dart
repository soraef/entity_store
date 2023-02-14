import 'dart:async';

import 'package:entity_store/entity_store.dart';
import 'package:entity_store/src/single_source_store.dart';

abstract class StoreEventHandler {
  void handleEvent<Id, E extends Entity<Id>>(StoreEvent<Id, E> event);
  bool shouldListenTo<Id, E extends Entity<Id>>(StoreEvent<Id, E> event);
}

class StoreEventDispatcher {
  final _controller = StreamController<StoreEvent>.broadcast();
  final SingleSourceStoreMixin _source;

  Stream<StoreEvent> get eventStream => _controller.stream;

  StoreEventDispatcher(this._source) {
    _controller.stream.listen((event) {
      event.apply(_source);
    });
  }

  void dispatch<Id, E extends Entity<Id>>(StoreEvent<Id, E> event) {
    _controller.sink.add(event);
  }

  E? get<Id, E extends Entity<Id>>(Id id) {
    return _source.value.get<Id, E>(id);
  }

  EntityMap<Id, E> where<Id, E extends Entity<Id>>([
    bool Function(E) test = testAlwaysTrue,
  ]) {
    return _source.value.where(test);
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

import 'package:entity_store/entity_store.dart';
import 'package:riverpod/riverpod.dart';

abstract class RiverpodStoreBase<T> extends StateNotifier<T>
    implements StoreBase<T> {
  RiverpodStoreBase({
    required T initState,
  }) : super(initState);

  @override
  void update(Updater<T> updater) {
    state = updater(state);
  }

  @override
  T get value => state;

  @override
  void register(StoreEventDispatcher dispatcher) {
    dispatcher.register(this);
  }
}

abstract class IRiverpodEntityMapStore<Id, E extends Entity<Id>>
    extends RiverpodStoreBase<EntityMap<Id, E>>
    implements EntityStoreBase<Id, E, EntityMap<Id, E>> {
  IRiverpodEntityMapStore({
    required super.initState,
  });
}

class RiverpodEntityMapStore<Id, E extends Entity<Id>>
    extends IRiverpodEntityMapStore<Id, E> with EntityMapStoreMixin<Id, E> {
  RiverpodEntityMapStore({
    required super.initState,
  });
}

abstract class IRiverpodEntityStore<Id, E extends Entity<Id>>
    extends RiverpodStoreBase<E?> implements EntityStoreBase<Id, E, E?> {
  IRiverpodEntityStore({
    required super.initState,
  });
}

class RiverpodEntityStore<Id, E extends Entity<Id>>
    extends IRiverpodEntityStore<Id, E> with EntityStoreMixin<Id, E> {
  RiverpodEntityStore({
    required super.initState,
  });
}

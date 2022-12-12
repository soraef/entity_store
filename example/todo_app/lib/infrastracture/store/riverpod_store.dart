import 'package:entity_store/entity_store.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class RiverpodStoreBase<T> extends StateNotifier<T>
    implements StoreBase<T> {
  RiverpodStoreBase(super.state);

  @override
  void update(Updater<T> updater) {
    state = updater(state);
  }

  @override
  T get value => state;
}

abstract class IRiverpodEntityMapStore<Id, E extends Entity<Id>>
    extends RiverpodStoreBase<EntityMap<Id, E>>
    implements EntityStoreBase<Id, E, EntityMap<Id, E>> {
  IRiverpodEntityMapStore(super.state);
}

class RiverpodEntityMapStore<Id, E extends Entity<Id>>
    extends IRiverpodEntityMapStore<Id, E> with EntityMapStoreMixin<Id, E> {
  RiverpodEntityMapStore(super.state);
}

import 'package:entity_store/entity_store.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class RiverpodStore<T> extends StateNotifier<T> implements IStore<T> {
  RiverpodStore(super.state);

  @override
  void update(Updater<T> updater) {
    state = updater(state);
  }

  @override
  T get value => state;
}

class RiverpodEntityMapStore<Id, E extends Entity<Id>>
    extends RiverpodStore<EntityMap<Id, E>> with IEntityMapStore<Id, E> {
  RiverpodEntityMapStore(super.state);
}

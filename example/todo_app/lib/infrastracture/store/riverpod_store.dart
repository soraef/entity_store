import 'package:entity_store/entity_store.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RiverpodStore<T> extends StateNotifier<T> implements Store<T> {
  RiverpodStore(super.state);

  @override
  void update(Updater<T> updater) {
    state = updater(state);
  }

  @override
  T get value => state;
}

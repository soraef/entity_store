import 'package:entity_store/entity_store.dart';
import 'package:riverpod/riverpod.dart';

class SingleSourceStoreRiverpod extends StateNotifier<EntityStore>
    with EntityStoreMixin {
  SingleSourceStoreRiverpod() : super(EntityStore.empty());

  @override
  void update(Updater<EntityStore> updater) {
    state = updater(state);
  }

  @override
  EntityStore get value => state;
}

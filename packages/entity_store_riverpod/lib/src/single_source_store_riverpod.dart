import 'package:entity_store/entity_store.dart';
import 'package:riverpod/riverpod.dart';

class SingleSourceStoreRiverpod extends StateNotifier<EntityMapContainer>
    with SingleSourceStoreMixin {
  SingleSourceStoreRiverpod() : super(EntityMapContainer.empty());

  @override
  void update(Updater<EntityMapContainer> updater) {
    state = updater(state);
  }

  @override
  EntityMapContainer get value => state;
}

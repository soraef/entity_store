import 'package:entity_store/entity_store.dart';
import 'package:flutter/foundation.dart';

class EntityStoreNotifier extends ChangeNotifier with EntityStoreMixin {
  EntityStore state = EntityStore.empty();

  @override
  void update(Updater<EntityStore> updater) {
    state = updater(state);
    notifyListeners();
  }

  @override
  EntityStore get value => state;
}

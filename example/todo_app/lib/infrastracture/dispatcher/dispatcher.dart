import 'package:entity_store/entity_store.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final entityStore = StateNotifierProvider<EntityStoreNotifier, EntityStore>(
  (ref) => EntityStoreNotifier(),
);

final entityStoreController = Provider(
  (ref) => EntityStoreController(ref.read(entityStore.notifier)),
);

final debugger = Provider(
  (ref) => StoreEventPrintDebugger(
    ref.read(entityStoreController).eventStream,
    showEntityDetail: true,
  ),
);

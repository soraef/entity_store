import 'package:entity_store/entity_store.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final entityStore = Provider(
  (ref) => EntityStoreNotifier(),
);

final entityStoreController = Provider(
  (ref) => EntityStoreController(ref.read(entityStore)),
);

final debugger = Provider(
  (ref) => EntityStorePrintDebugger(
    ref.read(entityStoreController).eventStream,
    showEntityDetail: true,
  ),
);

import 'package:entity_store/entity_store.dart';
import 'package:entity_store_riverpod/entity_store_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final source =
    StateNotifierProvider<SingleSourceStoreRiverpod, EntityMapContainer>(
  (ref) => SingleSourceStoreRiverpod(),
);

final dispater = Provider(
  (ref) => StoreEventDispatcher(ref.read(source.notifier)),
);

final debugger = Provider(
  (ref) => StoreEventPrintDebugger(
    ref.read(dispater).eventStream,
    showEntityDetail: true,
  ),
);

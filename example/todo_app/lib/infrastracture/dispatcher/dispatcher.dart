import 'package:entity_store/entity_store.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/application/store/entity_store/todo_store.dart';

final eventDispatcher = Provider(
  (ref) => StoreEventDispatcher()..register(ref.read(todoStore.notifier)),
);

final debugger = Provider(
  (ref) => StoreEventPrintDebugger(
    ref.read(eventDispatcher).eventStream,
    showEntityDetail: true,
  ),
);

import 'store_event_dispatcher.dart';

abstract class IRepo {
  final StoreEventDispatcher eventDispatcher;

  IRepo(this.eventDispatcher);
}

import 'package:skyreach_result/skyreach_result.dart';

import 'entity.dart';
import 'store_event_dispatcher.dart';

abstract class IRepo<Id, E extends Entity<Id>> {
  final StoreEventDispatcher dispater;

  IRepo(this.dispater);

  Future<Result<E?, Exception>> get(
    Id id, {
    GetOption option = const GetOption(),
  });

  Future<List<E>> getByIds(List<Id> ids) async {
    final future = ids.map((id) => get(id));
    final docs = await Future.wait(future);

    return docs.map((e) => e.mapErr((p0) => null)).whereType<E>().toList();
  }
}

class GetOption {
  final bool useCache;

  const GetOption({
    this.useCache = false,
  });
}

abstract class IRepoFactory {
  IRepoFactory fromSubCollection<Id, E extends Entity<Id>>(Id id);
  IRepo<Id, E> getRepo<Id, E extends Entity<Id>>();
}

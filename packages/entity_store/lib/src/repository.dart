import 'package:skyreach_result/skyreach_result.dart';

import 'entity.dart';
import 'store_event_dispatcher.dart';

abstract class IRepo<Id, E extends Entity<Id>> {
  final StoreEventDispatcher dispater;
  IRepo(this.dispater);

  Future<Result<E?, Exception>> get(
    Id id, {
    GetOptions options = const GetOptions(),
  });

  Future<Result<E, Exception>> save(
    E entity, {
    SaveOptions options = const SaveOptions(),
  });

  Future<Result<E, Exception>> delete(
    E entity, {
    DeleteOptions options = const DeleteOptions(),
  });

  Future<List<E>> getByIds(List<Id> ids) async {
    final future = ids.map((id) => get(id));
    final docs = await Future.wait(future);

    return docs.map((e) => e.mapErr((p0) => null)).whereType<E>().toList();
  }
}

class GetOptions {
  final bool useCache;

  const GetOptions({
    this.useCache = false,
  });
}

class SaveOptions {
  final bool merge;
  const SaveOptions({
    this.merge = false,
  });
}

class DeleteOptions {
  const DeleteOptions();
}

abstract class IRepoFactory {
  IRepoFactory fromSubCollection<Id, E extends Entity<Id>>(Id id);
  IRepo<Id, E> getRepo<Id, E extends Entity<Id>>();
}

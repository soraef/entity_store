import 'package:collection/collection.dart';
import 'package:entity_store/entity_store.dart';

mixin PaginationMixIn<Id, E extends Entity<Id>> {
  IRepository<Id, E> get repo;

  Id? get latestId;
  set latestId(Id? latestId);

  bool get hasMore;
  set hasMore(bool more);

  Future<void> cursor(Query<Id, E> query) async {
    if (!hasMore) return;
    final entities = await repo
        .list(latestId != null ? query.startAfterId(latestId as Id) : query);

    if (entities.isErr ||
        entities.ok.isEmpty ||
        entities.ok.lastOrNull?.id == latestId) {
      hasMore = false;
    }

    if (entities.isOk) {
      latestId = entities.ok.lastOrNull?.id;
    }
  }

  Future<void> loadMore({
    int limit = 10,
  });
}

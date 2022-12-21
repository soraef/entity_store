import 'package:collection/collection.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';

mixin PaginationMixIn<Id, E extends Entity<Id>> {
  FirestoreList<Id, E> get repo;

  Id? get latestId;
  set latestId(Id? latestId);

  bool get hasMore;
  set hasMore(bool more);

  Future<void> cursor({
    required FirestoreCollection<Id, E> collection,
    FirestoreWhere? where,
    String? orderByField,
    int? limit,
  }) async {
    if (!hasMore) return;
    final entities = await repo.list(
      collection: collection,
      afterId: latestId,
      where: where,
      orderByField: orderByField,
      limit: limit,
    );

    if (entities.isFailure ||
        entities.success.isEmpty ||
        entities.success.lastOrNull?.id == latestId) {
      hasMore = false;
    }

    if (entities.isSuccess) {
      latestId = entities.success.lastOrNull?.id;
    } else {
      print((entities.failure as FirestoreRequestFailure).message);
    }
  }

  Future<void> loadMore({
    int limit = 10,
  });
}

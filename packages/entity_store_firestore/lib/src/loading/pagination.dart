import 'package:collection/collection.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:entity_store_firestore/src/factory/factory.dart';

mixin PaginationMixIn<Id, E extends Entity<Id>> {
  FirestoreRepo<Id, E> get repo;

  Id? get latestId;
  set latestId(Id? latestId);

  bool get hasMore;
  set hasMore(bool more);

  Future<void> cursor({
    FirestoreWhere? where,
    String? orderByField,
    int? limit,
  }) async {
    if (!hasMore) return;
    final entities = await repo.list(
      afterId: latestId,
      where: where,
      orderByField: orderByField,
      limit: limit,
    );

    if (entities.isErr ||
        entities.ok.isEmpty ||
        entities.ok.lastOrNull?.id == latestId) {
      hasMore = false;
    }

    if (entities.isOk) {
      latestId = entities.ok.lastOrNull?.id;
    } else {
      print((entities.err as FirestoreRequestFailure).message);
    }
  }

  Future<void> loadMore({
    int limit = 10,
  });
}

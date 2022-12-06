import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/src/collection.dart';
import 'package:entity_store_firestore/src/firestore_repository.dart';
import 'package:entity_store_firestore/src/firestore_where.dart';
import 'package:result_type/result_type.dart';

class FirestoreListParams<Id, E extends Entity<Id>>
    implements IListParams<Id, E> {
  final FirestoreCollection<Id, E> collection;
  final int? limit;
  final String? orderByField;
  final FirestoreWhere? where;
  final Id? afterId;

  FirestoreListParams({
    required this.collection,
    this.limit,
    this.orderByField,
    this.where,
    this.afterId,
  });

  Future<Query<dynamic>> getQuery(CollectionReference<dynamic> ref) async {
    Query<dynamic> query = ref;

    if (where != null) {
      query = where!(ref);
    }

    if (afterId != null) {
      query = query.startAfterDocument(
        await collection.documentRef(afterId as Id).get(),
      );
    }

    if (orderByField != null) {
      query = query.orderBy(orderByField!);
    }

    if (limit != null) {
      query = query.limit(limit!);
    }

    return query;
  }
}

mixin FirestoreList<Id, E extends Entity<Id>,
        Params extends FirestoreListParams<Id, E>>
    implements FirestoreRepository<Id, E>, RepositoryList<Id, E, Params> {
  @override
  Future<Result<List<E>, Exception>> list(
      covariant FirestoreListParams params) async {
    var ref = params.collection.collectionRef();
    final query = params.getQuery(ref);
    final snapshot = await (await query).get();
    return Success(_convert(snapshot.docs).toList());
  }

  List<E> _convert(List<QueryDocumentSnapshot<dynamic>> docs) {
    return docs
        .map((e) => e.data())
        .map((data) {
          if (data == null) return null;

          return converter.fromJson(data);
        })
        .whereType<E>()
        .toList();
  }
}

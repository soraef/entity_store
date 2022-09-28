import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/src/collection.dart';
import 'package:entity_store_firestore/src/firestore_id.dart';
import 'package:entity_store_firestore/src/firestore_repository.dart';
import 'package:entity_store_firestore/src/firestore_where.dart';

abstract class IFirestoreListParams implements ListParams {
  final FirestoreCollection collection;

  IFirestoreListParams(this.collection);
  Query<dynamic> getQuery(CollectionReference<dynamic> ref);
}

class FirestoreListParams implements IFirestoreListParams {
  @override
  final FirestoreCollection collection;
  final int? limit;
  final String? orderByField;

  FirestoreListParams({
    required this.collection,
    this.limit,
    this.orderByField,
  });

  @override
  Query getQuery(CollectionReference ref) {
    Query<dynamic> query = ref;

    if (orderByField != null) {
      query = query.orderBy(orderByField!);
    }

    if (limit != null) {
      query = query.limit(limit!);
    }

    return query;
  }
}

class CustomFirestoreListParams implements IFirestoreListParams {
  @override
  final FirestoreCollection collection;
  final FirestoreWhere where;

  CustomFirestoreListParams({
    required this.collection,
    required this.where,
  });

  @override
  Query getQuery(CollectionReference ref) {
    return where(ref);
  }
}

mixin FirestoreList<Id extends FirestoreId, E extends Entity<Id>>
    implements FirestoreRepository<Id, E>, RepositoryList<E> {
  @override
  Future<List<E>> list(covariant IFirestoreListParams params) async {
    var ref = params.collection.collectionRef();
    final query = params.getQuery(ref);
    final snapshot = await query.get();
    return _convert(snapshot.docs).toList();
  }

  List<E> _convert(List<QueryDocumentSnapshot<dynamic>> docs) {
    return docs
        .map((e) => e.data())
        .map((data) {
          if (data == null) return null;

          try {
            return converter.fromJson(data);
          } catch (e) {
            return null;
          }
        })
        .whereType<E>()
        .toList();
  }
}

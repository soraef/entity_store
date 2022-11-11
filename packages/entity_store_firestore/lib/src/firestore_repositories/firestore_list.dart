import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/src/collection.dart';
import 'package:entity_store_firestore/src/firestore_repository.dart';
import 'package:entity_store_firestore/src/firestore_where.dart';

class FirestoreListParams<Id, E extends Entity<Id>>
    implements IListParams<Id, E> {
  final FirestoreCollection<Id, E> collection;
  final int? limit;
  final String? orderByField;
  final FirestoreWhere? where;

  FirestoreListParams({
    required this.collection,
    this.limit,
    this.orderByField,
    this.where,
  });

  Query<dynamic> getQuery(CollectionReference<dynamic> ref) {
    Query<dynamic> query = ref;

    if (where != null) {
      query = where!(ref);
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
  Future<List<E>> list(covariant FirestoreListParams params) async {
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

          return converter.fromJson(data);
        })
        .whereType<E>()
        .toList();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/src/collection.dart';
import 'package:entity_store_firestore/src/firestore_id.dart';
import 'package:entity_store_firestore/src/firestore_repository.dart';
import 'package:entity_store_firestore/src/firestore_where.dart';

class CustomFirestoreCursorParams<Id> implements CursorParams {
  final FirestoreCollection collection;
  final FirestoreWhere where;
  final Id? latestId;

  CustomFirestoreCursorParams({
    required this.collection,
    required this.where,
    this.latestId,
  });
}

class FirestoreCursorParams<Id> implements CursorParams {
  final FirestoreCollection collection;
  final int? limit;
  final String? orderByField;
  final Id? latestId;

  FirestoreCursorParams({
    required this.collection,
    this.latestId,
    this.limit,
    this.orderByField,
  });
}

mixin FirestoreCursor<Id, E extends Entity<Id>>
    implements FirestoreRepository<Id, E>, RepositoryCursor<E> {
  @override
  Future<List<E>> cursor(CursorParams params) async {
    if (params is FirestoreCursorParams<Id>) {
      final colRef = params.collection.collectionRef();
      Query<dynamic> query = colRef;

      if (params.orderByField != null) {
        query = query.orderBy(params.orderByField!);
      }

      if (params.limit != null) {
        query = query.limit(params.limit!);
      }

      if (params.latestId != null) {
        query = colRef.startAfterDocument(
            await params.collection.documentRef(params.latestId!).get());
      }

      final snapshot = await query.get();
      return _convert(snapshot.docs);
    } else if (params is CustomFirestoreCursorParams<Id>) {
      final colRef = params.collection.collectionRef();
      var query = params.where(colRef);

      if (params.latestId != null) {
        query = query.startAfterDocument(
            await params.collection.documentRef(params.latestId!).get());
      }

      final snapshot = await query.get();
      return _convert(snapshot.docs);
    }

    throw UnimplementedError("Error");
  }

  List<E> _convert(List<QueryDocumentSnapshot<dynamic>> docs) {
    return docs
        .map((e) => e.data())
        .map((e) {
          try {
            return converter.fromJson(e);
          } catch (e) {
            return null;
          }
        })
        .whereType<E>()
        .toList();
  }
}

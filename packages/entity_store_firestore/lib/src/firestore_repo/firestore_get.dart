import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:result_type/result_type.dart';

mixin FirestoreGet<Id, E extends Entity<Id>> implements FirestoreRepo<Id, E> {
  Future<Result<E?, Exception>> get(Id id) async {
    late DocumentSnapshot<dynamic> doc;
    try {
      doc = await getCollection(id).documentRef(id).get();
    } on FirebaseException catch (e) {
      return Failure(
        FirestoreRequestException(
          entityType: E,
          code: e.code,
          method: "get",
        ),
      );
    }

    if (doc.exists) {
      try {
        final entity = converter.fromJson(doc.data());
        eventDispatcher.dispatch(GetEvent<Id, E>(entity: entity));
        return Success(entity);
      } catch (e) {
        return Failure(
          JsonConverterException(
            entityType: E,
            method: "get",
            fetched: doc.data(),
          ),
        );
      }
    }

    return Success(null);
  }

  Future<List<E>> getByIds(List<Id> ids) async {
    final future = ids.map((id) => get(id));
    final docs = await Future.wait(future);

    return docs.map((e) => e.mapError((p0) => null)).whereType<E>().toList();
  }
}

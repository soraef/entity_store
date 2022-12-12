import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:result_type/result_type.dart';

mixin FirestoreBatchingDelete<Id, E extends Entity<Id>>
    implements FirestoreRepo<Id, E> {
  Future<Result<E, Exception>> delete(E entity) async {
    try {
      final collection = getCollection(entity.id);
      await collection.collectionRef().doc(batchId(entity)).set(
        {
          fieldName: {
            collection.toDocumentId(entity.id): FieldValue.delete(),
          },
        },
        SetOptions(merge: true),
      );
      eventDispatcher.dispatch(DeleteEvent<Id, E>(entityId: entity.id));
      return Success(entity);
    } on FirebaseException catch (e) {
      return Failure(
        FirestoreRequestException(
          entityType: E,
          code: e.code,
          method: "firestore.batching.delete",
        ),
      );
    }
  }

  String get fieldName;
  String batchId(E entity);
}
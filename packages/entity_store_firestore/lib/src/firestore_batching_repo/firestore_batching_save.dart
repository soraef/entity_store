import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:result_type/result_type.dart';

mixin FirestoreBatchingSave<Id, E extends Entity<Id>>
    implements FirestoreRepo<Id, E> {
  Future<Result<E, Exception>> save(E entity) async {
    try {
      final collection = getCollection(entity.id);
      await collection.collectionRef().doc(batchId(entity)).set(
        {
          fieldName: {
            collection.toDocumentId(entity.id): converter.toJson(entity),
          },
          ...toJson(entity)
        },
        SetOptions(merge: true),
      );
      eventDispatcher.dispatch(SaveEvent<Id, E>(entity: entity));
      return Success(entity);
    } on FirebaseException catch (e) {
      return Failure(
        FirestoreRequestException(
          entityType: E,
          code: e.code,
          method: "firestore.batching.save",
        ),
      );
    }
  }

  Future<Result<List<E>, Exception>> saveAll(Iterable<E> entities) async {
    if (entities.isEmpty) {
      return Failure(Exception());
    }

    try {
      final entity = entities.first;
      final collection = getCollection(entity.id);

      await collection.collectionRef().doc(batchId(entity)).set(
        {
          fieldName: {
            for (final e in entities)
              collection.toDocumentId(e.id): converter.toJson(e),
          },
          ...toJson(entity)
        },
        SetOptions(merge: true),
      );

      for (final entity in entities) {
        eventDispatcher.dispatch(SaveEvent<Id, E>(entity: entity));
      }

      return Success(entities.toList());
    } on FirebaseException catch (e) {
      return Failure(
        FirestoreRequestException(
          entityType: E,
          code: e.code,
          method: "firestore.batching.saveAll",
        ),
      );
    }
  }

  String get fieldName;
  String batchId(E entity);
  Map<String, dynamic> toJson(E entity);
}

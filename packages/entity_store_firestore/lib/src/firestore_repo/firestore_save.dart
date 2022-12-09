import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:entity_store_firestore/src/exception.dart';
import 'package:result_type/result_type.dart';

mixin FirestoreSave<Id, E extends Entity<Id>> implements FirestoreRepo<Id, E> {
  Future<Result<E, Exception>> save(
    E entity, {
    bool merge = false,
  }) async {
    try {
      await getCollection(entity.id)
          .documentRef(entity.id)
          .set(converter.toJson(entity), SetOptions(merge: merge));
      eventDispatcher.dispatch(SaveEvent<Id, E>(entity: entity));
      return Success(entity);
    } on FirebaseException catch (e) {
      return Failure(
        FirestoreRequestException(
          entityType: E,
          code: e.code,
          method: "save",
        ),
      );
    }
  }

  Future<Result<Iterable<E>, Exception>> saveAll(
    Iterable<E> entities, {
    bool merge = false,
  }) async {
    final futureList = entities.map((e) => save(e));
    final results = await Future.wait(futureList);
    if (results.every((e) => e.isSuccess)) {
      return Success(results.map((e) => e.success));
    } else {
      return results.firstWhere((e) => e.isFailure).map((p0) => []);
    }
  }
}

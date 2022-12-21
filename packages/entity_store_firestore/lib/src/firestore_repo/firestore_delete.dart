import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:result_type/result_type.dart';

mixin FirestoreDelete<Id, E extends Entity<Id>>
    implements FirestoreRepo<Id, E> {
  Future<Result<E, Exception>> delete(E entity) async {
    try {
      await getCollection(entity.id).documentRef(entity.id).delete();
      eventDispatcher.dispatch(DeleteEvent<Id, E>(entityId: entity.id));
      return Success(entity);
    } on FirebaseException catch (e) {
      return Failure(
        FirestoreRequestFailure(
          entityType: E,
          code: e.code,
          method: "delete",
          message: e.message,
          exception: e,
        ),
      );
    }
  }
}

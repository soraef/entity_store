import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:meta/meta.dart';
import 'package:result_type/result_type.dart';

mixin FirestoreUpdate<Id, E extends Entity<Id>>
    implements FirestoreRepo<Id, E> {
  @experimental
  Future<Result<E, Exception>> update(
    Id id,
    E Function(E prev) updater,
  ) async {
    try {
      final entity = await FirebaseFirestore.instance
          .runTransaction<E>((transaction) async {
        final ref = getCollection(id).documentRef(id);
        final doc = await transaction.get(ref);
        final entity = converter.fromJson(doc.data());
        final newEntity = updater(entity);
        transaction.update(ref, converter.toJson(newEntity));
        return newEntity;
      });
      eventDispatcher.dispatch(SaveEvent<Id, E>(entity: entity));
      return Success(entity);
    } catch (e) {
      return Failure(Exception());
    }
  }
}

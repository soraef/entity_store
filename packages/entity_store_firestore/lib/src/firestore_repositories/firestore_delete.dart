import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/src/firestore_id.dart';
import 'package:entity_store_firestore/src/firestore_repository.dart';

mixin FirestoreDelete<Id extends FirestoreId, E extends Entity<Id>>
    implements FirestoreRepository<Id, E>, RepositoryDelete<E> {
  @override
  Future<void> delete(E entity) async {
    await entity.id.documentRef().delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/src/firestore_id.dart';
import 'package:entity_store_firestore/src/firestore_repository.dart';

mixin FirestoreSave<Id extends FirestoreId, E extends Entity<Id>>
    implements FirestoreRepository<Id, E>, RepositorySave<E> {
  @override
  Future<void> save(E entity) async {
    await entity.id
        .documentRef()
        .set(converter.toJson(entity), SetOptions(merge: true));
  }

  @override
  Future<void> saveAll(Iterable<E> entities) async {
    final futureList = entities.map((e) => save(e));
    await Future.wait(futureList);
  }
}

mixin FirestorePartialSave<Id extends FirestoreId, E extends Entity<Id>>
    implements FirestoreRepository<Id, E>, RepositoryPartialSave<Id, E> {
  @override
  Future<void> partialSave(PartialEntity<Id, E> partial) async {
    await partial.id
        .documentRef()
        .set(partial.toJson(), SetOptions(merge: true));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/src/firestore_repository.dart';

mixin FirestoreSave<Id, E extends Entity<Id>>
    implements FirestoreRepository<Id, E>, RepositorySave<Id, E> {
  @override
  Future<void> save(E entity) async {
    await getCollection(entity.id)
        .documentRef(entity.id)
        .set(converter.toJson(entity), SetOptions(merge: true));
  }

  @override
  Future<void> saveAll(Iterable<E> entities) async {
    final futureList = entities.map((e) => save(e));
    await Future.wait(futureList);
  }
}

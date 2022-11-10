import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/src/firestore_repository.dart';

mixin FirestoreDelete<Id, E extends Entity<Id>>
    implements FirestoreRepository<Id, E>, RepositoryDelete<E> {
  @override
  Future<void> delete(E entity) async {
    await getCollection(entity.id).documentRef(entity.id).delete();
  }
}

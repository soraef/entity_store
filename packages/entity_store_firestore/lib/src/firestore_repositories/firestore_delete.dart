import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/src/firestore_repository.dart';
import 'package:result_type/result_type.dart';

mixin FirestoreDelete<Id, E extends Entity<Id>>
    implements FirestoreRepository<Id, E>, RepositoryDelete<Id, E> {
  @override
  Future<Result<E, Exception>> delete(E entity) async {
    await getCollection(entity.id).documentRef(entity.id).delete();
    return Success(entity);
  }
}

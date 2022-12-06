import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/src/firestore_repository.dart';
import 'package:result_type/result_type.dart';

mixin FirestoreSave<Id, E extends Entity<Id>>
    implements FirestoreRepository<Id, E>, RepositorySave<Id, E> {
  @override
  Future<Result<E, Exception>> save(
    E entity, {
    SaveOptions options = const SaveOptions(),
  }) async {
    await getCollection(entity.id)
        .documentRef(entity.id)
        .set(converter.toJson(entity), SetOptions(merge: options.merge));
    return Success(entity);
  }

  Future<Result<Iterable<E>, Exception>> saveAll(Iterable<E> entities) async {
    final futureList = entities.map((e) => save(e));
    final results = await Future.wait(futureList);
    if (results.every((e) => e.isSuccess)) {
      return Success(results.map((e) => e.success));
    } else {
      return results.firstWhere((e) => e.isFailure).map((p0) => []);
    }
  }
}

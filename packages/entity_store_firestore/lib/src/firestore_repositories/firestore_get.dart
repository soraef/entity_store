import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/src/firestore_repository.dart';
import 'package:result_type/result_type.dart';

mixin FirestoreGet<Id, E extends Entity<Id>>
    implements FirestoreRepo<Id, E>, RepositoryGet<Id, E> {
  @override
  Future<Result<E?, Exception>> get(Id id) async {
    final doc = await getCollection(id).documentRef(id).get();
    if (doc.exists) {
      return Success(converter.fromJson(doc.data()));
    }
    return Success(null);
  }

  @override
  Future<Result<List<E>, Exception>> getByIds(List<Id> ids) async {
    final future = ids.map((id) => get(id));
    final docs = await Future.wait(future);
    return Success(docs.map((e) => e.success).whereType<E>().toList());
  }
}

import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/src/firestore_id.dart';
import 'package:entity_store_firestore/src/firestore_repository.dart';

mixin FirestoreGet<Id extends FirestoreId, E extends Entity<Id>>
    implements FirestoreRepository<Id, E>, RepositoryGet<Id, E> {
  @override
  Future<E?> get(Id id) async {
    try {
      final doc = await id.documentRef().get();
      return converter.fromJson(doc.data());
    } catch (_) {}

    return null;
  }

  @override
  Future<List<E>> getByIds(List<Id> ids) async {
    final future = ids.map((id) => get(id));
    final docs = await Future.wait(future);
    return docs.whereType<E>().toList();
  }
}

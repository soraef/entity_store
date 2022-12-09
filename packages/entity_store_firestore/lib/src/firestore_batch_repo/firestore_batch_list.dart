import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:result_type/result_type.dart';

mixin FirestoreMapFieldList<BatchId, Id, E extends Entity<Id>>
    implements FirestoreRepo<Id, E> {
  Future<Result<List<E>, Exception>> list({
    required FirestoreCollection<Id, E> collection,
    required BatchId batchId,
  }) async {
    final query = collection.collectionRef().doc(documentId);
    final snapshot = await query.get();
    return Success(_convert(snapshot));
  }

  List<E> _convert(DocumentSnapshot<dynamic> doc) {
    final data = doc.data();
    if (data == null) return [];
    var json = data as Map<String, dynamic>;
    var result = <E>[];

    final entities = json[fieldName] as Map<String, dynamic>?;

    for (final entityJson in entities?.values ?? []) {
      try {
        result.add(converter.fromJson(entityJson));
      } catch (_) {}
    }

    return result;
  }

  String get fieldName;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';

mixin FirestoreMapFieldSave<Id extends FirestoreId, E extends Entity<Id>>
    implements FirestoreRepository<Id, E>, RepositorySave<E> {
  @override
  Future<void> save(E entity) async {
    await entity.id.collection.collectionRef().doc(batchId(entity)).set(
      {
        fieldName: {
          entity.id.value: converter.toJson(entity),
        },
        ...toJson(entity)
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> saveAll(Iterable<E> entities) async {
    if (entities.isEmpty) {
      throw Error();
    }

    final entity = entities.first;

    await entity.id.collection.collectionRef().doc(batchId(entity)).set(
      {
        fieldName: {
          for (final e in entities) e.id.value: converter.toJson(e),
        },
        ...toJson(entity)
      },
      SetOptions(merge: true),
    );
  }

  String get fieldName;
  String batchId(E entity);
  Map<String, dynamic> toJson(E entity);
}

mixin FirestoreMapFieldDelete<Id extends FirestoreId, E extends Entity<Id>>
    implements FirestoreRepository<Id, E>, RepositoryDelete<E> {
  @override
  Future<void> delete(E entity) async {
    await entity.id.collection.collectionRef().doc(batchId(entity)).set(
      {
        fieldName: {
          entity.id.value: FieldValue.delete(),
        },
      },
      SetOptions(merge: true),
    );
  }

  String get fieldName;
  String batchId(E entity);
}

class MapFieldListParams implements ListParams {
  final FirestoreCollection collection;
  final String documentId;

  MapFieldListParams({
    required this.collection,
    required this.documentId,
  });

  DocumentReference getDoc(CollectionReference ref) {
    return collection.collectionRef().doc(documentId);
  }
}

mixin FirestoreMapFieldList<Id extends FirestoreId, E extends Entity<Id>>
    implements FirestoreRepository<Id, E>, RepositoryList<E> {
  @override
  Future<List<E>> list(covariant MapFieldListParams params) async {
    var ref = params.collection.collectionRef();
    final query = params.getDoc(ref);
    final snapshot = await query.get();
    return _convert(snapshot);
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

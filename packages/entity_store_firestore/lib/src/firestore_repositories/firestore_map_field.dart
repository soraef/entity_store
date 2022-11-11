import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';

mixin FirestoreMapFieldSave<Id, E extends Entity<Id>>
    implements FirestoreRepository<Id, E>, RepositorySave<Id, E> {
  @override
  Future<void> save(E entity) async {
    final collection = getCollection(entity.id);
    await collection.collectionRef().doc(batchId(entity)).set(
      {
        fieldName: {
          collection.toDocumentId(entity.id): converter.toJson(entity),
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
    final collection = getCollection(entity.id);

    await collection.collectionRef().doc(batchId(entity)).set(
      {
        fieldName: {
          for (final e in entities)
            collection.toDocumentId(e.id): converter.toJson(e),
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

mixin FirestoreMapFieldDelete<Id, E extends Entity<Id>>
    implements FirestoreRepository<Id, E>, RepositoryDelete<Id, E> {
  @override
  Future<void> delete(E entity) async {
    final collection = getCollection(entity.id);
    await collection.collectionRef().doc(batchId(entity)).set(
      {
        fieldName: {
          collection.toDocumentId(entity.id): FieldValue.delete(),
        },
      },
      SetOptions(merge: true),
    );
  }

  String get fieldName;
  String batchId(E entity);
}

class MapFieldListParams implements IListParams {
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

mixin FirestoreMapFieldList<Id, E extends Entity<Id>>
    implements
        FirestoreRepository<Id, E>,
        RepositoryList<E, MapFieldListParams> {
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

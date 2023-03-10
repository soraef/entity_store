import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:meta/meta.dart';
import 'package:skyreach_result/skyreach_result.dart';

mixin FirestoreBucketEntityNotifier<Id, E extends Entity<Id>>
    on EntityChangeNotifier<Id, E> implements IFirestoreEntityNotifier<Id, E> {
  Map<String, dynamic> toJson(E entity);
  E fromJson(Map<String, dynamic> json);
  String idToString(Id id);
  String bucketIdToString(E entity);
  String get bucketFieldName;

  @override
  @protected
  Future<Result<E?, Exception>> protectedGetAndNotify(
    CollectionReference collection,
    Id id,
  ) async {
    late QuerySnapshot<Object?> snapshot;
    try {
      snapshot =
          await collection.where("_ids", arrayContains: idToString(id)).get();
    } on FirebaseException catch (e) {
      return Result.err(
        FirestoreRequestFailure(
          entityType: E,
          code: e.code,
          message: e.message,
          exception: e,
        ),
      );
    }

    final result = <E>[];
    try {
      for (final doc in snapshot.docs) {
        result.addAll(
          _convertBucketingResult(doc, bucketFieldName),
        );
      }
    } on Exception catch (e) {
      return Result.err(
        JsonConverterFailure(
          entityType: E,
          fetched: snapshot.docs.map((e) => e.data()),
          exception: e,
        ),
      );
    }
    notifyListComplete(result);
    final entity = result.firstWhereOrNull((e) => e.id == id);
    return Result.ok(entity);
  }

  @override
  @protected
  Future<Result<Id, Exception>> protectedDeleteAndNotify(
    CollectionReference collection,
    Id id,
  ) async {
    final result = await protectedGetAndNotify(collection, id);
    if (result.isErr) {
      return Result.err(result.err);
    }

    final entity = result.ok;
    if (entity == null) {
      notifyDeleteComplete(id);
      return Result.ok(id);
    }

    try {
      await collection.doc(bucketIdToString(entity)).set(
        {
          bucketFieldName: {
            idToString(entity.id): FieldValue.delete(),
          },
          "_ids": FieldValue.arrayRemove([
            idToString(entity.id),
          ]),
        },
        SetOptions(merge: true),
      );
      notifyDeleteComplete(id);
      return Result.ok(id);
    } on FirebaseException catch (e) {
      return Result.err(
        FirestoreRequestFailure(
          entityType: E,
          code: e.code,
          message: e.message,
          exception: e,
        ),
      );
    }
  }

  @override
  @protected
  Future<Result<List<E>, Exception>> protectedListAndNotify(Query ref) async {
    late QuerySnapshot<dynamic> snapshot;
    try {
      snapshot = await ref.get();
    } on FirebaseException catch (e) {
      return Result.err(
        FirestoreRequestFailure(
          entityType: E,
          code: e.code,
          message: e.message,
          exception: e,
        ),
      );
    }

    final result = <E>[];
    try {
      for (final doc in snapshot.docs) {
        result.addAll(
          _convertBucketingResult(doc, bucketFieldName),
        );
      }
    } on Exception catch (e) {
      return Result.err(
        JsonConverterFailure(
          entityType: E,
          fetched: snapshot.docs.map((e) => e.data()),
          exception: e,
        ),
      );
    }
    notifyListComplete(result);
    return Result.ok(result);
  }

  @override
  @protected
  Future<Result<E, Exception>> protectedSaveAndNotify(
    CollectionReference collection,
    E entity, {
    bool? merge,
    List<Object>? mergeFields,
  }) async {
    try {
      await collection.doc(bucketIdToString(entity)).set(
        {
          "id": bucketIdToString(entity),
          bucketFieldName: {
            idToString(entity.id): toJson(entity),
          },
          "_ids": FieldValue.arrayUnion([idToString(entity.id)])
        },
        SetOptions(merge: true),
      );
      notifySaveComplete(entity);
      return Result.ok(entity);
    } on FirebaseException catch (e) {
      return Result.err(
        FirestoreRequestFailure(
          entityType: E,
          code: e.code,
          message: e.message,
          exception: e,
        ),
      );
    }
  }

  List<E> _convertBucketingResult(
    DocumentSnapshot<dynamic> doc,
    String fieldName,
  ) {
    final data = doc.data();
    if (data == null) return [];
    var json = data as Map<String, dynamic>;
    var result = <E>[];

    final entities = json[fieldName] as Map<String, dynamic>?;

    for (final entityJson in entities?.values ?? []) {
      result.add(fromJson(entityJson));
    }

    return result;
  }
}

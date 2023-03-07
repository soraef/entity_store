import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:meta/meta.dart';
import 'package:skyreach_result/skyreach_result.dart';

mixin FirestoreEntityNotifier<Id, E extends Entity<Id>>
    on EntityChangeNotifier<Id, E> {
  Map<String, dynamic> toJson(E entity);
  E fromJson(Map<String, dynamic> json);
  String toDocumentId(Id id);

  @protected
  Future<Result<E?, Exception>> protectedGetAndNotify(
    CollectionReference collection,
    Id id,
  ) async {
    late DocumentSnapshot<dynamic> doc;

    try {
      doc = await collection.doc(toDocumentId(id)).get();
    } on FirebaseException catch (e) {
      return Result.err(
        FirestoreRequestFailure(
          entityType: E,
          code: e.code,
          method: "get",
          message: e.message,
          exception: e,
        ),
      );
    }

    if (doc.exists) {
      try {
        final entity = fromJson(doc.data());
        notifyGetComplete(entity);
        return Result.ok(entity);
      } on Exception catch (e) {
        return Result.err(
          JsonConverterFailure(
            entityType: E,
            method: "get",
            fetched: doc.data(),
            exception: e,
          ),
        );
      }
    } else {
      notifyEntityNotFound(id);
    }

    return Result.ok(null);
  }

  @protected
  Future<Result<Id, Exception>> protectedDeleteAndNotify(
    CollectionReference collection,
    Id id,
  ) async {
    try {
      await collection.doc(toDocumentId(id)).delete();
      notifyDeleteComplete(id);
      return Result.ok(id);
    } on FirebaseException catch (e) {
      return Result.err(
        FirestoreRequestFailure(
          entityType: E,
          code: e.code,
          method: "delete",
          message: e.message,
          exception: e,
        ),
      );
    }
  }

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
          method: "list",
          message: e.message,
          exception: e,
        ),
      );
    }

    try {
      final data = _convert(snapshot.docs).toList();
      notifyListComplete(data);
      return Result.ok(data);
    } on Exception catch (e) {
      return Result.err(
        JsonConverterFailure(
          entityType: E,
          method: "list",
          fetched: snapshot.docs.map((e) => e.data()).toList(),
          exception: e,
        ),
      );
    }
  }

  @protected
  Future<Result<E, Exception>> protectedSaveAndNotify(
    CollectionReference collection,
    E entity, {
    bool? merge,
    List<Object>? mergeFields,
  }) async {
    try {
      await collection.doc(toDocumentId(entity.id)).set(
            toJson(entity),
            merge != null || mergeFields != null
                ? SetOptions(merge: merge, mergeFields: mergeFields)
                : null,
          );
      notifySaveComplete(entity);
      return Result.ok(entity);
    } on FirebaseException catch (e) {
      return Result.err(
        FirestoreRequestFailure(
          entityType: E,
          code: e.code,
          method: "save",
          message: e.message,
          exception: e,
        ),
      );
    }
  }

  List<E> _convert(List<QueryDocumentSnapshot<dynamic>> docs) {
    return docs
        .map((e) => e.data())
        .map((data) {
          if (data == null) return null;
          return fromJson(data);
        })
        .whereType<E>()
        .toList();
  }
}

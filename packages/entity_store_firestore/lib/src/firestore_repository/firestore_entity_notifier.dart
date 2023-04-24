import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:meta/meta.dart';
import 'package:skyreach_result/skyreach_result.dart';

abstract class IFirestoreEntityNotifier<Id, E extends Entity<Id>> {
  @protected
  Future<Result<E?, Exception>> protectedGetAndNotify(
    CollectionReference collection,
    Id id, {
    bool? useCache,
  });
  @protected
  Future<Result<Id, Exception>> protectedDeleteAndNotify(
    CollectionReference collection,
    Id id,
  );
  @protected
  Future<Result<List<E>, Exception>> protectedListAndNotify(Query ref);
  @protected
  Future<Result<E, Exception>> protectedSaveAndNotify(
    CollectionReference collection,
    E entity, {
    bool? merge,
    List<Object>? mergeFields,
  });

  @protected
  Future<Result<E?, Exception>> protectedCreateOrUpdateAndNotify(
    CollectionReference collection,
    Id id,
    E? Function() creater,
    E? Function(E prev) updater, {
    bool? merge,
    bool? useTransaction,
    List<Object>? mergeFields,
  });
}

mixin FirestoreEntityNotifier<Id, E extends Entity<Id>>
    on EntityChangeNotifier<Id, E> implements IFirestoreEntityNotifier<Id, E> {
  Map<String, dynamic> toJson(E entity);
  E fromJson(Map<String, dynamic> json);
  String idToString(Id id);

  @override
  Future<Result<E?, Exception>> protectedGetAndNotify(
    CollectionReference collection,
    Id id, {
    bool? useCache,
  }) async {
    late DocumentSnapshot<dynamic> doc;

    if (useCache == true) {
      final entity = controller.getById<Id, E>(id);
      if (entity != null) {
        notifyGetComplete(entity);
        return Result.ok(entity);
      }
    }

    try {
      doc = await collection.doc(idToString(id)).get();
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

    if (doc.exists) {
      try {
        final entity = fromJson(doc.data());
        notifyGetComplete(entity);
        return Result.ok(entity);
      } on Exception catch (e) {
        return Result.err(
          JsonConverterFailure(
            entityType: E,
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

  @override
  Future<Result<Id, Exception>> protectedDeleteAndNotify(
    CollectionReference collection,
    Id id,
  ) async {
    try {
      await collection.doc(idToString(id)).delete();
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

    try {
      final data = _convert(snapshot.docs).toList();
      notifyListComplete(data);
      return Result.ok(data);
    } on Exception catch (e) {
      return Result.err(
        JsonConverterFailure(
          entityType: E,
          fetched: snapshot.docs.map((e) => e.data()).toList(),
          exception: e,
        ),
      );
    }
  }

  @override
  Future<Result<E, Exception>> protectedSaveAndNotify(
    CollectionReference collection,
    E entity, {
    bool? merge,
    List<Object>? mergeFields,
  }) async {
    try {
      await collection.doc(idToString(entity.id)).set(
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
          message: e.message,
          exception: e,
        ),
      );
    }
  }

  @override
  Future<Result<E?, Exception>> protectedCreateOrUpdateAndNotify(
    CollectionReference collection,
    Id id,
    E? Function() creater,
    E? Function(E prev) updater, {
    bool? merge,
    bool? useTransaction,
    bool? useCache,
    List<Object>? mergeFields,
  }) async {
    assert(
      !(useTransaction == true && useCache == true),
      'useTransaction and useCache cannot be true at the same time.',
    );

    /// get and set using transaction
    Future<E?> getAndSetTransaction() async {
      return await collection.firestore.runTransaction((transaction) async {
        final doc = await transaction.get(collection.doc(idToString(id)));
        final entity = doc.exists ? fromJson(doc.data() as dynamic) : null;
        final newEntity = entity == null ? creater() : updater(entity);
        if (newEntity != null) {
          transaction.set(
            collection.doc(idToString(id)),
            toJson(newEntity),
            merge != null || mergeFields != null
                ? SetOptions(merge: merge, mergeFields: mergeFields)
                : null,
          );
        }

        return newEntity;
      });
    }

    /// get and set using no transaction
    Future<E?> getAndSetNoTransaction() async {
      E? entity;
      if (useCache == true) {
        entity = controller.getById<Id, E>(id);
      }

      if (entity == null) {
        final doc = await collection.doc(idToString(id)).get();
        entity = doc.exists ? fromJson(doc.data() as dynamic) : null;
      }

      final newEntity = entity == null ? creater() : updater(entity);
      if (newEntity != null) {
        await collection.doc(idToString(id)).set(
              toJson(newEntity),
              merge != null || mergeFields != null
                  ? SetOptions(merge: merge, mergeFields: mergeFields)
                  : null,
            );
      }

      return newEntity;
    }

    try {
      final entity = await useTransaction.orTrue.ifMap(
        ifTrue: getAndSetTransaction,
        ifFalse: getAndSetNoTransaction,
      );

      if (entity == null) {
        notifyEntityNotFound(id);
      } else {
        notifySaveComplete(entity);
      }

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

extension _BoolX on bool {
  T ifMap<T>({
    required T Function() ifTrue,
    required T Function() ifFalse,
  }) {
    if (this) {
      return ifTrue();
    } else {
      return ifFalse();
    }
  }
}

extension _BoolOrNullX on bool? {
  T ifMap<T>({
    required T Function() ifTrue,
    required T Function() ifFalse,
    required T Function() ifNull,
  }) {
    if (this == null) {
      return ifNull();
    } else if (this!) {
      return ifTrue();
    } else {
      return ifFalse();
    }
  }

  /// if null, return false
  bool get orFalse => this ?? false;

  /// if null, return true
  bool get orTrue => this ?? true;
}

import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:entity_store_firestore/src/repository/firestore_repo.dart';
import 'package:entity_store_firestore/src/repository/query.dart';
import 'package:skyreach_result/skyreach_result.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as f;

class FirestoreGeneralRepo<Id, E extends Entity<Id>>
    extends FirestoreRepo<Id, E> {
  FirestoreGeneralRepo(
    super.collection,
    super.dispatcher,
    super.collectionType,
  );

  GeneralCollection<Id, E> get generalCollection => collectionType.general;

  @override
  Future<Result<E, Exception>> delete(
    E entity, {
    DeleteOptions options = const DeleteOptions(),
  }) async {
    try {
      await collection.doc(collectionType.idToString(entity.id)).delete();
      dispater.dispatch(DeleteEvent<Id, E>.now(entity.id));
      return Result.ok(entity);
    } on f.FirebaseException catch (e) {
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

  @override
  Future<Result<E?, Exception>> get(
    Id id, {
    GetOptions options = const GetOptions(),
  }) async {
    if (options.useCache) {
      final entity = dispater.get<Id, E>(id);
      if (entity != null) {
        return Result.ok(entity);
      }
    }

    late f.DocumentSnapshot<dynamic> doc;
    try {
      doc = await collection.doc(collectionType.idToString(id)).get();
    } on f.FirebaseException catch (e) {
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
        final entity = collectionType.fromJson(doc.data());
        dispater.dispatch(GetEvent<Id, E>.now(id, entity));
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
    }
    return Result.ok(null);
  }

  @override
  Future<Result<List<E>, Exception>> list(Query<Id, E> query) async {
    f.Query<dynamic> ref = collection;
    ref = query.buildFilterQuery(ref);

    final startAfterId = query.getStartAfterId;
    ref = query.buildSortQuery(ref);
    if (startAfterId != null) {
      late f.DocumentSnapshot<dynamic> snapshot;
      try {
        snapshot = await collection
            .doc(
              collectionType.idToString(startAfterId),
            )
            .get();
      } on f.FirebaseException catch (e) {
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
      ref = ref.startAfterDocument(snapshot);
    }

    ref = query.buildLimitQuery(ref);

    late f.QuerySnapshot<dynamic> snapshot;
    try {
      snapshot = await ref.get();
    } on f.FirebaseException catch (e) {
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
      dispater.dispatch(ListEvent<Id, E>.now(data));
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

  @override
  Future<Result<E, Exception>> save(
    E entity, {
    SaveOptions options = const SaveOptions(),
  }) async {
    try {
      await collection.doc(collectionType.idToString(entity.id)).set(
            collectionType.toJson(entity),
            f.SetOptions(merge: options.merge),
          );
      dispater.dispatch(SaveEvent<Id, E>.now(entity));
      return Result.ok(entity);
    } on f.FirebaseException catch (e) {
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

  List<E> _convert(List<f.QueryDocumentSnapshot<dynamic>> docs) {
    return docs
        .map((e) => e.data())
        .map((data) {
          if (data == null) return null;
          return collectionType.fromJson(data);
        })
        .whereType<E>()
        .toList();
  }
}

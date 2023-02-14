import 'package:cloud_firestore/cloud_firestore.dart' as f;
import 'package:entity_store/entity_store.dart';
import 'package:entity_store_firestore/entity_store_firestore.dart';
import 'package:meta/meta.dart';
import 'package:skyreach_result/skyreach_result.dart';

class FirestoreRepoFactorySettings {
  final Map<Type, CollectionType> _collectionTypeMap;
  final StoreEventDispatcher dispatcher;

  factory FirestoreRepoFactorySettings.init(StoreEventDispatcher dispatcher) {
    return FirestoreRepoFactorySettings._({}, dispatcher);
  }

  FirestoreRepoFactorySettings._(
    this._collectionTypeMap,
    this.dispatcher,
  );

  FirestoreRepoFactorySettings regist<Id, E extends Entity<Id>>(
    CollectionType<Id, E> collectionType,
  ) {
    return FirestoreRepoFactorySettings._(
      {..._collectionTypeMap, E: collectionType},
      dispatcher,
    );
  }

  String collectionName<Id, E extends Entity<Id>>() {
    return collectionType<Id, E>().collectionName;
  }

  CollectionType<Id, E> collectionType<Id, E extends Entity<Id>>() {
    return _collectionTypeMap[E] as CollectionType<Id, E>;
  }
}

class FirestoreRepoFactory implements IRepoFactory {
  final FirestoreRepoFactorySettings settings;

  factory FirestoreRepoFactory.init(
    FirestoreRepoFactorySettings settings,
    f.FirebaseFirestore firestore,
  ) {
    return FirestoreRepoFactory._(settings, firestore);
  }

  FirestoreRepoFactory._(
    this.settings,
    f.FirebaseFirestore firestore,
  ) {
    getCollectionRef = (path) => firestore.collection(path);
  }

  FirestoreRepoFactory._document(
    this.settings,
    f.DocumentReference document,
  ) {
    getCollectionRef = (path) => document.collection(path);
  }

  @override
  FirestoreRepoFactory fromSubCollection<Id, E extends Entity<Id>>(Id id) {
    final collectionName = settings.collectionName<Id, E>();
    final entityType = settings.collectionType<Id, E>();
    final documentRef = getCollectionRef(collectionName).doc(
      entityType.idToString(id),
    );
    return FirestoreRepoFactory._document(
      settings,
      documentRef,
    );
  }

  late final f.CollectionReference Function(String collectionPath)
      getCollectionRef;

  @override
  FirestoreRepo<Id, E> getRepo<Id, E extends Entity<Id>>() {
    final collectionName = settings.collectionName<Id, E>();
    final collectionRef = getCollectionRef(collectionName);
    return FirestoreRepo<Id, E>(
      settings.collectionType<Id, E>(),
      collectionRef,
      settings.dispatcher,
    );
  }
}

class FirestoreRepo<Id, E extends Entity<Id>> extends IRepo<Id, E> {
  final StoreEventDispatcher dispatcher;
  final f.CollectionReference collection;
  final CollectionType<Id, E> collectionType;

  FirestoreRepo(
    this.collectionType,
    this.collection,
    this.dispatcher,
  ) : super(dispatcher);

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

  Future<Result<List<E>, Exception>> list({
    int? limit,
    String? orderByField,
    FirestoreWhere? where,
    Id? afterId,
  }) async {
    var ref = collection;
    f.Query<dynamic> query = ref;

    if (where != null) {
      query = where(ref);
    }

    if (afterId != null) {
      late f.DocumentSnapshot<dynamic> snapshot;
      try {
        snapshot =
            await collection.doc(collectionType.idToString(afterId)).get();
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
      query = query.startAfterDocument(snapshot);
    }

    if (orderByField != null) {
      query = query.orderBy(orderByField);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    late f.QuerySnapshot<dynamic> snapshot;
    try {
      snapshot = await query.get();
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
  Future<Result<E, Exception>> save(E entity,
      {SaveOptions options = const SaveOptions()}) async {
    try {
      await collection.doc(collectionType.idToString(entity.id)).set(
          collectionType.toJson(entity), f.SetOptions(merge: options.merge));
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

  Future<Result<Iterable<E>, Exception>> saveAll(
    Iterable<E> entities, {
    bool merge = false,
  }) async {
    final futureList = entities.map((e) => save(e));
    final results = await Future.wait(futureList);
    if (results.every((e) => e.isOk)) {
      return Result.ok(results.map((e) => e.ok));
    } else {
      return results.firstWhere((e) => e.isErr).mapOk((p0) => []);
    }
  }

  @experimental
  Future<Result<E, Exception>> update(
    Id id,
    E Function(E prev) updater,
  ) async {
    try {
      final entity = await collection.firestore.runTransaction<E>(
        (transaction) async {
          final ref = collection.doc(collectionType.idToString(id));
          final doc = await transaction.get<dynamic>(ref);
          final entity = collectionType.fromJson(doc.data());
          final newEntity = updater(entity);
          transaction.update(ref, collectionType.toJson(newEntity));
          return newEntity;
        },
      );
      dispater.dispatch(SaveEvent<Id, E>.now(entity));
      return Result.ok(entity);
    } catch (e) {
      return Result.err(Exception());
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

// ignore_for_file: unused_element

part of '../firestore_repository.dart';

typedef CreateRepository<T, Id> = T Function(
    BaseFirestoreRepository parent, Id id);

abstract class FirestoreRepository<Id, E extends Entity<Id>>
    extends FirestoreRepositoryWithContainer<Id, E> {
  @override
  final EntityStoreController controller;
  final FirebaseFirestore instance;
  String get collectionId;

  FirestoreRepository({
    required this.controller,
    required this.instance,
  });

  @override
  CollectionReference<Map<String, dynamic>> get collectionRef =>
      instance.collection(collectionId);
}

abstract class FirestoreSubCollectionRepository<Id, E extends Entity<Id>>
    extends FirestoreRepositoryWithContainer<Id, E> implements SubCollection {
  @override
  final EntityStoreController controller;
  final String parentDocumentId;
  final BaseFirestoreRepository parentRepository;

  FirestoreSubCollectionRepository({
    required this.controller,
    required this.parentRepository,
    required this.parentDocumentId,
  });

  String get collectionId;

  @override
  CollectionReference<Map<String, dynamic>> get collectionRef =>
      parentRepository.collectionRef
          .doc(parentDocumentId)
          .collection(collectionId);
}

abstract class SubCollection {}

abstract class FirestoreRepositoryWithContainer<Id, E extends Entity<Id>>
    extends BaseFirestoreRepository<Id, E>
    with EntityChangeNotifier<Id, E>
    implements Repository<Id, E>, EntityStoreRepository<Id, E> {
  final Map<Type, CreateRepository<Object?, Id>> _container = {};

  TRepo getRepository<TRepo extends SubCollection>(
    Id id,
  ) {
    if (_container[TRepo] == null) {
      throw ArgumentError("$TRepo is Not regist in $runtimeType");
    }

    return _container[TRepo]!(this, id) as TRepo;
  }

  void registRepository<TRepo extends SubCollection>(
      CreateRepository<TRepo, Id> repo) {
    _container[TRepo] = repo;
  }

  @override
  DocumentReference getDocumentRef(Id id) {
    return collectionRef.doc(idToString(id));
  }
}

abstract class BaseFirestoreRepository<Id, E extends Entity<Id>>
    with EntityChangeNotifier<Id, E>
    implements Repository<Id, E>, EntityStoreRepository<Id, E> {
  CollectionReference<Map<String, dynamic>> get collectionRef;

  @override
  Future<Result<Id, Exception>> deleteById(
    Id id, {
    DeleteOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null && transaction is! FirestoreTransactionContext) {
      throw ArgumentError("transaction must be FirestoreTransactionContext");
    }

    FirestoreTransactionContext? firestoreTransaction;
    if (transaction != null) {
      firestoreTransaction = transaction as FirestoreTransactionContext;
    }

    return _protectedDeleteAndNotify(
      collectionRef,
      id,
      transaction: firestoreTransaction,
    );
  }

  @override
  Future<Result<E, Exception>> delete(
    E entity, {
    DeleteOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw UnimplementedError("delete with transaction is not implemented");
    }

    final deleteByIdResult = await deleteById(entity.id);
    if (deleteByIdResult.isFailure) {
      return Result.failure(deleteByIdResult.failure);
    }
    return Result.success(entity);
  }

  @override
  Future<Result<List<E>, Exception>> findAll({
    FindAllOptions? options,
    TransactionContext? transaction,
  }) {
    if (transaction != null) {
      throw UnimplementedError("findAll with transaction is not implemented");
    }

    return query().findAll(
      options: options,
    );
  }

  @override
  Future<Result<E?, Exception>> findOne({
    FindOneOptions? options,
    TransactionContext? transaction,
  }) {
    if (transaction != null) {
      throw UnimplementedError("findOne with transaction is not implemented");
    }
    return query().findOne(
      options: options,
    );
  }

  @override
  Future<Result<int, Exception>> count({
    CountOptions? options,
  }) {
    return query().count(
      options: options,
    );
  }

  @override
  Future<Result<E?, Exception>> findById(
    Id id, {
    FindByIdOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null && transaction is! FirestoreTransactionContext) {
      throw ArgumentError("transaction must be FirestoreTransactionContext");
    }

    FirestoreTransactionContext? firestoreTransaction;
    if (transaction != null) {
      firestoreTransaction = transaction as FirestoreTransactionContext;
    }

    return _protectedGetAndNotify(
      collectionRef,
      id,
      transaction: firestoreTransaction,
      options: options,
    );
  }

  @override
  IRepositoryQuery<Id, E> query() {
    return FirestoreRepositoryQuery(this);
  }

  @override
  Future<Result<E, Exception>> save(
    E entity, {
    SaveOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null && transaction is! FirestoreTransactionContext) {
      throw ArgumentError("transaction must be FirestoreTransactionContext");
    }

    FirestoreTransactionContext? firestoreTransaction;
    if (transaction != null) {
      firestoreTransaction = transaction as FirestoreTransactionContext;
    }

    return _protectedSaveAndNotify(
      collectionRef,
      entity,
      transaction: firestoreTransaction,
    );
  }

  @override
  Future<Result<E?, Exception>> upsert(
    Id id, {
    required E? Function() creater,
    required E? Function(E prev) updater,
    UpsertOptions? options,
  }) async {
    return _protectedCreateOrUpdateAndNotify(
      collectionRef,
      id,
      creater,
      updater,
    );
  }

  @override
  Stream<Result<E?, Exception>> observeById(
    Id id, {
    ObserveByIdOptions? options,
  }) {
    return _protectedObserveById(collectionRef, id);
  }

  DocumentReference getDocumentRef(Id id);

  String idToString(Id id);

  Future<Result<E?, Exception>> _protectedGetAndNotify(
    CollectionReference collection,
    Id id, {
    FindByIdOptions? options,
    // FetchPolicy fetchPolicy = FetchPolicy.persistent,
    FirestoreTransactionContext? transaction,
  }) async {
    late DocumentSnapshot<dynamic> doc;

    var entity = controller.getById<Id, E>(id);

    final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);

    /// get using transaction
    if (transaction != null) {
      final ref = collection.doc(idToString(id));
      doc = await transaction.value.get(ref);
    } else {
      /// get using no transaction
      if (fetchPolicy == FetchPolicy.storeOnly) {
        return Result.success(entity);
      }

      if (fetchPolicy == FetchPolicy.storeFirst) {
        if (entity != null) {
          return Result.success(entity);
        }
      }

      try {
        doc = await collection.doc(idToString(id)).get();
      } on FirebaseException catch (e) {
        return Result.failure(
          FirestoreRequestFailure(
            entityType: E,
            code: e.code,
            message: e.message,
            exception: e,
          ),
        );
      }
    }

    if (doc.exists) {
      try {
        var entity = fromJson(doc.data());
        notifyGetComplete(entity);
        return Result.success(entity);
      } on Exception catch (e) {
        return Result.failure(
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

    return Result.success(null);
  }

  Future<Result<Id, Exception>> _protectedDeleteAndNotify(
    CollectionReference collection,
    Id id, {
    DeleteOptions? options,
    FirestoreTransactionContext? transaction,
  }) async {
    if (transaction != null) {
      final ref = collection.doc(idToString(id));
      transaction.value.delete(ref);

      // notify after commit
      transaction.addOnCommitFunction(() {
        notifyDeleteComplete(id);
      });
      return Result.success(id);
    } else {
      try {
        await collection.doc(idToString(id)).delete();
        notifyDeleteComplete(id);
        return Result.success(id);
      } on FirebaseException catch (e) {
        return Result.failure(
          FirestoreRequestFailure(
            entityType: E,
            code: e.code,
            message: e.message,
            exception: e,
          ),
        );
      }
    }
  }

  Future<Result<List<E>, Exception>> _protectedListAndNotify(
    Query ref,
    Object? options,
  ) async {
    late QuerySnapshot<dynamic> snapshot;
    try {
      snapshot = await ref.get();
    } on FirebaseException catch (e) {
      // failed-preconditionの場合
      if (e.code == 'failed-precondition') {
        if (e.message?.contains('The query requires an index') == true) {
          // ignore: avoid_print
          print(e.message);
        }
      }
      return Result.failure(
        FirestoreRequestFailure(
          entityType: E,
          code: e.code,
          message: e.message,
          exception: e,
        ),
      );
    }

    try {
      var data = _convert(snapshot.docs).toList();
      notifyListComplete(data);
      return Result.success(data);
    } on Exception catch (e) {
      return Result.failure(
        JsonConverterFailure(
          entityType: E,
          fetched: snapshot.docs.map((e) => e.data()).toList(),
          exception: e,
        ),
      );
    }
  }

  Future<Result<E, Exception>> _protectedSaveAndNotify(
    CollectionReference collection,
    E entity, {
    SaveOptions? options,
    FirestoreTransactionContext? transaction,
  }) async {
    final merge = MergeOptions.getMerge(options);
    final mergeFields = MergeOptions.getMergeFields(options);

    if (transaction != null) {
      final ref = collection.doc(idToString(entity.id));
      transaction.value.set(
        ref,
        toJson(entity),
        SetOptions(merge: merge, mergeFields: mergeFields),
      );

      // notify after commit
      transaction.addOnCommitFunction(() {
        notifySaveComplete(entity);
      });

      return Result.success(entity);
    } else {
      try {
        await collection.doc(idToString(entity.id)).set(
              toJson(entity),
              merge != null || mergeFields != null
                  ? SetOptions(merge: merge, mergeFields: mergeFields)
                  : null,
            );
        notifySaveComplete(entity);
        return Result.success(entity);
      } on FirebaseException catch (e) {
        return Result.failure(
          FirestoreRequestFailure(
            entityType: E,
            code: e.code,
            message: e.message,
            exception: e,
          ),
        );
      }
    }
  }

  Future<Result<E?, Exception>> _protectedCreateOrUpdateAndNotify(
    CollectionReference collection,
    Id id,
    E? Function() creater,
    E? Function(E prev) updater, {
    UpsertOptions? options,
    // FetchPolicy fetchPolicy = FetchPolicy.persistent,
    // bool? merge,
    // bool? useTransaction,
    // List<Object>? mergeFields,
  }) async {
    final merge = MergeOptions.getMerge(options);
    final mergeFields = MergeOptions.getMergeFields(options);
    final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);
    final useTransaction = UseTransactionOptions.getUseTransaction(options);

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

      if (fetchPolicy == FetchPolicy.storeOnly ||
          fetchPolicy == FetchPolicy.storeFirst) {
        entity = controller.getById<Id, E>(id);
      }

      if (fetchPolicy == FetchPolicy.persistent ||
          (entity == null && fetchPolicy == FetchPolicy.storeFirst)) {
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

      return Result.success(entity);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirestoreRequestFailure(
          entityType: E,
          code: e.code,
          message: e.message,
          exception: e,
        ),
      );
    }
  }

  Stream<Result<E?, Exception>> _protectedObserveById(
    CollectionReference<Map<String, dynamic>> collectionRef,
    Id id, {
    ObserveByIdOptions? options,
  }) {
    return collectionRef.doc(idToString(id)).snapshots().map((event) {
      if (event.exists) {
        try {
          final entity = fromJson(event.data() as dynamic);
          notifyGetComplete(entity);
          return Result.success(entity);
        } on Exception catch (e) {
          return Result.failure(
            JsonConverterFailure(
              entityType: E,
              fetched: event.data(),
              exception: e,
            ),
          );
        }
      } else {
        notifyEntityNotFound(id);
        return Result.success(null);
      }
    });
  }

  Stream<Result<List<EntityChange<E>>, Exception>> _protectedObserveCollection(
    Query collection,
  ) {
    return collection.snapshots().map((event) {
      final changes = event.docChanges.map((e) {
        final entity = fromJson(e.doc.data() as dynamic);
        if (e.type == DocumentChangeType.added) {
          return EntityChange<E>(
            entity: entity,
            changeType: ChangeType.created,
          );
        } else if (e.type == DocumentChangeType.modified) {
          return EntityChange<E>(
            entity: entity,
            changeType: ChangeType.updated,
          );
        } else if (e.type == DocumentChangeType.removed) {
          return EntityChange<E>(
            entity: entity,
            changeType: ChangeType.deleted,
          );
        } else {
          throw UnimplementedError();
        }
      }).toList();

      for (final change in changes) {
        if (change.changeType == ChangeType.created) {
          notifyGetComplete(change.entity);
        } else if (change.changeType == ChangeType.updated) {
          notifyGetComplete(change.entity);
        } else if (change.changeType == ChangeType.deleted) {
          notifyDeleteComplete(change.entity.id);
        }
      }
      return Result.success(changes);
    });
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
  bool get orTrue => this ?? true;
}

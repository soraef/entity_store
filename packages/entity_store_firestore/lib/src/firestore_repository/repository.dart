// ignore_for_file: unused_element

part of '../firestore_repository.dart';

typedef CreateRepository<T, Id> = T Function(
    BaseFirestoreRepository parent, Id id);

abstract class FirestoreRepository<Id, E extends Entity<Id>>
    extends FirestoreRepositoryWithContainer<Id, E> {
  @override
  final EntityStoreController controller;

  FirebaseFirestore get instance => _multiInstance[_currentInstanceId]!;

  String get collectionId;

  Map<String, FirebaseFirestore> _multiInstance = {};
  late String _currentInstanceId;

  FirestoreRepository({
    required this.controller,
    required FirebaseFirestore instance,
  }) {
    _currentInstanceId = 'default';
    _multiInstance[_currentInstanceId] = instance;
  }

  FirestoreRepository.multiInstance({
    required this.controller,
    required String instanceId,
    required Map<String, FirebaseFirestore> instances,
  }) {
    _multiInstance = instances;
    _currentInstanceId = instanceId;
  }

  @override
  CollectionReference<Map<String, dynamic>> get collectionRef =>
      instance.collection(collectionId);

  void setInstance(String instanceId) {
    _currentInstanceId = instanceId;
  }
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
  Future<Id> deleteById(
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

    return await _protectedDeleteAndNotify(
      collectionRef,
      id,
      transaction: firestoreTransaction,
    );
  }

  @override
  Future<E> delete(
    E entity, {
    DeleteOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw TransactionException("delete with transaction is not implemented");
    }

    await deleteById(entity.id);
    return entity;
  }

  @override
  Future<List<E>> findAll({
    FindAllOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw TransactionException("findAll with transaction is not implemented");
    }

    return await query().findAll(options: options);
  }

  @override
  Future<E?> findOne({
    FindOneOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw TransactionException("findOne with transaction is not implemented");
    }

    return await query().findOne(options: options);
  }

  @override
  Future<int> count({
    CountOptions? options,
  }) async {
    return await query().count(options: options);
  }

  @override
  Future<E?> findById(
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

    return await _protectedGetAndNotify(
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
  Future<E> save(
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

    return await _protectedSaveAndNotify(
      collectionRef,
      entity,
      transaction: firestoreTransaction,
      options: options,
    );
  }

  @override
  Future<E?> upsert(
    Id id, {
    required E? Function() creater,
    required E? Function(E prev) updater,
    UpsertOptions? options,
  }) async {
    return await _protectedCreateOrUpdateAndNotify(
      collectionRef,
      id,
      creater,
      updater,
      options: options,
    );
  }

  @override
  Stream<E?> observeById(
    Id id, {
    ObserveByIdOptions? options,
  }) {
    return _protectedObserveById(collectionRef, id);
  }

  DocumentReference getDocumentRef(Id id);

  @override
  String idToString(Id id);

  Future<E?> _protectedGetAndNotify(
    CollectionReference collection,
    Id id, {
    FindByIdOptions? options,
    FirestoreTransactionContext? transaction,
  }) async {
    var entity = controller.getById<Id, E>(id);
    final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);

    /// get using transaction
    if (transaction != null) {
      final ref = collection.doc(idToString(id));
      try {
        final doc = await transaction.value.get(ref);
        if (!doc.exists) {
          notifyEntityNotFound(id);
          return null;
        }

        entity = fromJson(doc.data() as Map<String, dynamic>);
        transaction.addOnCommitFunction(() {
          notifyGetComplete(entity!);
        });
        return entity;
      } catch (e) {
        if (e is FirebaseException) {
          throw DataSourceException(
            'Firestore get failed: ${e.code} - ${e.message}',
          );
        }
        throw DataSourceException('Failed to get document: ${e.toString()}');
      }
    } else {
      /// get using no transaction
      if (fetchPolicy == FetchPolicy.storeOnly) {
        return entity;
      }

      if (fetchPolicy == FetchPolicy.storeFirst) {
        if (entity != null) {
          return entity;
        }
      }

      try {
        final doc = await collection.doc(idToString(id)).get();
        if (!doc.exists) {
          notifyEntityNotFound(id);
          return null;
        }

        entity = fromJson(doc.data() as Map<String, dynamic>);
        notifyGetComplete(entity);
        return entity;
      } catch (e) {
        if (e is FirebaseException) {
          throw DataSourceException(
            'Firestore get failed: ${e.code} - ${e.message}',
          );
        }
        throw DataSourceException('Failed to get document: ${e.toString()}');
      }
    }
  }

  /// Delete document and notify to listeners
  Future<Id> _protectedDeleteAndNotify(
    CollectionReference<Map<String, dynamic>> collection,
    Id id, {
    FirestoreTransactionContext? transaction,
  }) async {
    try {
      await _protectedDelete(
        collection,
        id,
        transaction: transaction,
      );

      if (transaction != null) {
        transaction.addOnCommitFunction(() {
          notifyDeleteComplete(id);
        });
      } else {
        notifyDeleteComplete(id);
      }

      return id;
    } catch (e) {
      if (e is FirebaseException) {
        throw EntityDeleteException(id, reason: '${e.code} - ${e.message}');
      }
      throw EntityDeleteException(id, reason: e.toString());
    }
  }

  /// Delete document
  Future<void> _protectedDelete(
    CollectionReference<Map<String, dynamic>> collection,
    Id id, {
    FirestoreTransactionContext? transaction,
  }) async {
    final docRef = collection.doc(idToString(id));

    if (transaction != null) {
      transaction.value.delete(docRef);
      return;
    }

    await docRef.delete();
  }

  Future<List<E>> _protectedListAndNotify(
    Query ref,
    Object? options,
  ) async {
    try {
      final snapshot = await ref.get();
      final data = _convert(snapshot.docs).toList();
      notifyListComplete(data);
      return data;
    } on FirebaseException catch (e) {
      // failed-preconditionの場合
      if (e.code == 'failed-precondition') {
        if (e.message?.contains('The query requires an index') == true) {
          // ignore: avoid_print
          print(e.message);
        }
      }
      throw QueryException('Firestore query failed: ${e.code} - ${e.message}');
    } catch (e) {
      throw QueryException('Failed to execute query: ${e.toString()}');
    }
  }

  Future<E> _protectedSaveAndNotify(
    CollectionReference collection,
    E entity, {
    FirestoreTransactionContext? transaction,
    SaveOptions? options,
  }) async {
    try {
      final merge = MergeOptions.getMerge(options);
      final mergeFields = MergeOptions.getMergeFields(options);

      await _protectedSave(
        collection,
        entity,
        transaction: transaction,
        merge: merge,
        mergeFields: mergeFields,
      );

      if (transaction != null) {
        transaction.addOnCommitFunction(() {
          notifySaveComplete(entity);
        });
      } else {
        notifySaveComplete(entity);
      }

      return entity;
    } catch (e) {
      if (e is FirebaseException) {
        throw EntitySaveException(entity, reason: '${e.code} - ${e.message}');
      }
      throw EntitySaveException(entity, reason: e.toString());
    }
  }

  Future<void> _protectedSave(
    CollectionReference collection,
    E entity, {
    FirestoreTransactionContext? transaction,
    bool? merge,
    List<Object>? mergeFields,
  }) async {
    final ref = collection.doc(idToString(entity.id));
    final data = toJson(entity);

    final setOptions = merge != null || mergeFields != null
        ? SetOptions(merge: merge, mergeFields: mergeFields)
        : null;

    if (transaction != null) {
      transaction.value.set(ref, data, setOptions);
      return;
    }

    await ref.set(data, setOptions);
  }

  Future<E?> _protectedCreateOrUpdateAndNotify(
    CollectionReference collection,
    Id id,
    E? Function() creater,
    E? Function(E prev) updater, {
    UpsertOptions? options,
  }) async {
    try {
      final merge = MergeOptions.getMerge(options);
      final mergeFields = MergeOptions.getMergeFields(options);
      final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);
      final useTransaction = UseTransactionOptions.getUseTransaction(options);

      // トランザクション内で取得と保存を行う関数
      Future<E?> getAndSetWithTransaction() async {
        return await collection.firestore.runTransaction((transaction) async {
          final docRef = collection.doc(idToString(id));
          final doc = await transaction.get(docRef);

          final entity =
              doc.exists ? fromJson(doc.data() as Map<String, dynamic>) : null;
          final newEntity = entity == null ? creater() : updater(entity);

          if (newEntity != null) {
            final data = toJson(newEntity);
            final setOptions = merge != null || mergeFields != null
                ? SetOptions(merge: merge, mergeFields: mergeFields)
                : null;

            transaction.set(docRef, data, setOptions);

            // トランザクション完了後に通知するために、TransactionContextは使用できないので、
            // 直接通知処理を行う（コミット後に自動的に実行される）
            return newEntity;
          }

          return null;
        });
      }

      // トランザクションを使用しない通常の取得と保存
      Future<E?> getAndSetWithoutTransaction() async {
        E? entity;

        if (fetchPolicy == FetchPolicy.storeOnly ||
            fetchPolicy == FetchPolicy.storeFirst) {
          entity = controller.getById<Id, E>(id);
        }

        if (fetchPolicy == FetchPolicy.persistent ||
            (entity == null && fetchPolicy == FetchPolicy.storeFirst)) {
          entity = await findById(id,
              options: StorageFindByIdOptions(
                fetchPolicy: fetchPolicy,
              ));
        }

        final newEntity = entity == null ? creater() : updater(entity);

        if (newEntity != null) {
          // SaveOptionsを作成して必要なパラメータを渡す
          final saveOptions = options != null
              ? FirestoreSaveOptions(
                  merge: merge ?? true,
                  mergeFields: mergeFields?.cast<String>() ?? const [],
                )
              : null;

          return await save(newEntity, options: saveOptions);
        }

        return null;
      }

      // useTransactionの値に基づいて、適切な実装を選択
      final result = useTransaction == true
          ? await getAndSetWithTransaction()
          : await getAndSetWithoutTransaction();

      if (result != null) {
        notifySaveComplete(result);
      } else {
        notifyEntityNotFound(id);
      }

      return result;
    } catch (e) {
      if (e is FirebaseException) {
        throw RepositoryException(
          'Failed to upsert entity: ${e.code} - ${e.message}',
        );
      }
      throw RepositoryException('Failed to upsert entity: ${e.toString()}');
    }
  }

  Stream<E?> _protectedObserveById(
    CollectionReference collection,
    Id id,
  ) {
    try {
      final ref = collection.doc(idToString(id));
      return ref.snapshots().map((snapshot) {
        if (!snapshot.exists) {
          notifyEntityNotFound(id);
          return null;
        }

        final entity = fromJson(snapshot.data() as Map<String, dynamic>);
        notifyGetComplete(entity);
        return entity;
      });
    } catch (e) {
      throw RepositoryException('Failed to observe entity: ${e.toString()}');
    }
  }

  Stream<List<EntityChange<E>>> _protectedObserveCollection(
    Query collection,
  ) {
    try {
      return collection.snapshots().map((event) {
        final changes = event.docChanges.map((e) {
          try {
            final entity = fromJson(e.doc.data() as Map<String, dynamic>);
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
              throw UnimplementedError('未対応のドキュメント変更タイプ: ${e.type}');
            }
          } catch (e) {
            throw RepositoryException('ドキュメント変更の処理に失敗しました: ${e.toString()}');
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

        return changes;
      });
    } catch (e) {
      throw RepositoryException('コレクションの監視に失敗しました: ${e.toString()}');
    }
  }

  Iterable<E> _convert(List<QueryDocumentSnapshot> docs) sync* {
    for (var doc in docs) {
      try {
        yield fromJson(doc.data() as Map<String, dynamic>);
      } on Exception catch (e) {
        throw RepositoryException(
          'Error converting document: ${e.toString()}',
        );
      }
    }
  }

  @override
  Map<String, dynamic> toJson(E entity);

  @override
  E fromJson(Map<String, dynamic> json);
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

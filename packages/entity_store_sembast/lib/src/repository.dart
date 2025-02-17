import 'package:entity_store/entity_store.dart';
import 'package:entity_store_sembast/src/query.dart';
import 'package:sembast/sembast.dart';
import 'package:type_result/type_result.dart';
import 'storage_repository.dart'; // Entity, Result, RepositoryFilter, RepositorySort などの定義済みとする

/// Sembast 用に直接 Sembast の API を利用する Repository 実装
abstract class SembastRepository<Id, E extends Entity<Id>>
    with EntityChangeNotifier<Id, E>
    implements Repository<Id, E>, EntityStoreRepository<Id, E> {
  @override
  final EntityStoreController controller;

  final Database db;

  SembastRepository({required this.controller, required this.db});

  String get storeName;

  StoreRef<String, Map<String, Object?>> get store =>
      stringMapStoreFactory.store(storeName);

  @override
  Map<String, dynamic> toJson(E entity);

  @override
  E fromJson(Map<String, dynamic> json);

  @override
  Future<Result<E?, Exception>> findById(
    Id id, {
    FindByIdOptions? options,
    TransactionContext? transaction,
  }) async {
    try {
      final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);
      final enableBefore = BeforeCallbackOptions.getEnableBefore(options);
      final enableLoadEntity =
          LoadEntityCallbackOptions.getEnableLoadEntity(options);

      if (enableBefore) {
        final beforeFindByIdResult = await onBeforeFindById(id);
        if (beforeFindByIdResult.isFailure) {
          return Result.failure(beforeFindByIdResult.failure);
        }
      }

      final storeEntity = controller.getById<Id, E>(id);
      if (fetchPolicy == FetchPolicy.storeOnly) {
        return Result.success(storeEntity);
      }

      if (fetchPolicy == FetchPolicy.storeFirst && storeEntity != null) {
        return Result.success(storeEntity);
      }

      final record = await store.record(id.toString()).get(db);
      if (record == null) {
        notifyEntityNotFound(id);
        return Result.success(null);
      }

      var entity = fromJson(Map<String, dynamic>.from(record));
      if (enableLoadEntity) {
        final loadEntityResult = await onLoadEntity(entity);
        if (loadEntityResult.isFailure) {
          return Result.failure(loadEntityResult.failure);
        }
        entity = loadEntityResult.success;
      }

      notifyGetComplete(entity);
      return Result.success(entity);
    } catch (e) {
      return Result.failure(Exception('Failed to find entity: $e'));
    }
  }

  @override
  Future<Result<List<E>, Exception>> findAll({
    FindAllOptions? options,
    TransactionContext? transaction,
  }) async {
    try {
      final records = await store.find(db);
      final entities = records
          .map((r) => fromJson(Map<String, dynamic>.from(r.value)))
          .toList();
      return Result.success(entities);
    } catch (e) {
      return Result.failure(Exception('Failed to find all entities: $e'));
    }
  }

  @override
  Future<Result<E, Exception>> save(
    E entity, {
    SaveOptions? options,
    TransactionContext? transaction,
  }) async {
    try {
      final json = toJson(entity);
      await store.record(entity.id.toString()).put(db, json);
      notifySaveComplete(entity);
      return Result.success(entity);
    } catch (e) {
      return Result.failure(Exception('Failed to save entity: $e'));
    }
  }

  @override
  Future<Result<Id, Exception>> deleteById(
    Id id, {
    DeleteOptions? options,
    TransactionContext? transaction,
  }) async {
    try {
      await store.record(id.toString()).delete(db);
      notifyDeleteComplete(id);
      return Result.success(id);
    } catch (e) {
      return Result.failure(Exception('Failed to delete entity: $e'));
    }
  }

  @override
  Future<Result<E, Exception>> delete(
    E entity, {
    DeleteOptions? options,
    TransactionContext? transaction,
  }) async {
    final result = await deleteById(entity.id, options: options);
    return result.map(
      (success) => Result.success(entity),
      (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<int, Exception>> count({CountOptions? options}) async {
    try {
      final count = await store.count(db);
      return Result.success(count);
    } catch (e) {
      return Result.failure(Exception('Failed to count entities: $e'));
    }
  }

  /// クエリ処理は SembastRepositoryQuery 経由で行います
  @override
  IRepositoryQuery<Id, E> query() {
    return SembastRepositoryQuery<Id, E>(
      repository: this,
      db: db,
      store: store,
      toJson: toJson,
      fromJson: fromJson,
    );
  }

  @override
  Future<Result<E?, Exception>> findOne({
    FindOneOptions? options,
    TransactionContext? transaction,
  }) async {
    try {
      final record = await store.findFirst(db);
      if (record == null) {
        return Result.success(null);
      }

      final entity = fromJson(Map<String, dynamic>.from(record.value));
      return Result.success(entity);
    } catch (e) {
      return Result.failure(Exception('Failed to find one entity: $e'));
    }
  }

  @override
  Stream<Result<E?, Exception>> observeById(
    Id id, {
    ObserveByIdOptions? options,
  }) {
    final record = store.record(id.toString());
    return record.onSnapshot(db).map((snapshot) {
      if (snapshot == null) {
        notifyEntityNotFound(id);
        return Result.success(null);
      }

      try {
        final entity = fromJson(Map<String, dynamic>.from(snapshot.value));
        notifyGetComplete(entity);
        return Result.success(entity);
      } catch (e) {
        return Result.failure(Exception('Failed to observe entity: $e'));
      }
    });
  }

  @override
  Future<Result<E?, Exception>> upsert(
    Id id, {
    required E? Function() creater,
    required E? Function(E prev) updater,
    UpsertOptions? options,
  }) async {
    final findResult = await findById(id);
    if (findResult.isFailure) {
      return Result.failure(findResult.failure);
    }

    final existingEntity = findResult.success;
    final newEntity =
        existingEntity == null ? creater() : updater(existingEntity);

    if (newEntity == null) {
      return Result.success(null);
    }

    final saveResult = await save(newEntity);
    return saveResult.map(
      (success) => Result.success(newEntity),
      (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<void, Exception>> onBeforeSave(E entity) async {
    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> onBeforeDeleteById(Id id) async {
    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> onBeforeDelete(E entity) async {
    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> onBeforeFindById(Id id) async {
    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> onBeforeFindAll(
    IRepositoryQuery<Id, E> query,
  ) async {
    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> onBeforeCount() async {
    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> onBeforeFindOne(
    IRepositoryQuery<Id, E> query,
  ) async {
    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> onBeforeUpsert(Id id) async {
    return Result.success(null);
  }

  @override
  Future<Result<E, Exception>> onLoadEntity(E entity) async {
    return Result.success(entity);
  }
}

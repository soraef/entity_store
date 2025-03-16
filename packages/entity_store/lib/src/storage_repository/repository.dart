part of '../storage_repository.dart';

/// The StorageRepository is a repository that handles a generic storage as a data source.
///
/// This repository can save, read, delete, and update data regardless of where the data source is stored.
///
/// Saving and reading data to the data source is handled by the handler for the data source.
///
/// This repository can also read data from an external data source and cache it.
abstract class StorageRepository<Id, E extends Entity<Id>>
    with EntityChangeNotifier<Id, E>
    implements Repository<Id, E>, EntityStoreRepository<Id, E> {
  StorageRepository({
    required this.dataSourceHandler,
    required this.controller,
  }) {
    dataSourceHandler.toJson = toJson;
    dataSourceHandler.fromJson = fromJson;
    dataSourceHandler.idToString = idToString;
  }

  final IDataSourceHandler<Id, E> dataSourceHandler;

  @override
  final EntityStoreController controller;

  @override
  Future<Result<E?, Exception>> upsert(
    Id id, {
    required E? Function() creater,
    required E? Function(E prev) updater,
    UpsertOptions? options,
  }) async {
    final findResult = await findById(
      id,
      options: StorageFindByIdOptions(),
    );
    if (findResult.isFailure) {
      return Result.failure(findResult.failure);
    }

    var entity = findResult.success;

    final newEntity = entity == null ? creater() : updater(entity);

    if (newEntity != null) {
      final saveResult = await save(
        newEntity,
        options: StorageSaveOptions(),
      );
      if (saveResult.isFailure) {
        return Result.failure(saveResult.failure);
      }

      return Result.success(newEntity);
    } else {
      return Result.success(null);
    }
  }

  @override
  Future<Result<Id, Exception>> deleteById(
    Id id, {
    DeleteOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw UnimplementedError(
        'Transaction is not supported in StorageRepository',
      );
    }

    final deleteResult = await dataSourceHandler.delete(id);
    return deleteResult.map(
      (success) {
        notifyDeleteComplete(id);
        return Result.success(id);
      },
      (err) {
        return Result.failure(err);
      },
    );
  }

  @override
  Future<Result<E, Exception>> delete(
    E entity, {
    DeleteOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw UnimplementedError(
        'Transaction is not supported in StorageRepository',
      );
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
  }) async {
    if (transaction != null) {
      throw UnimplementedError(
        'Transaction is not supported in StorageRepository',
      );
    }

    final result = await query().findAll(
      options: options,
      transaction: transaction,
    );

    return result;
  }

  @override
  Future<Result<E?, Exception>> findById(
    Id id, {
    FindByIdOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw UnimplementedError(
        'Transaction is not supported in StorageRepository',
      );
    }

    final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);

    final storeEntity = controller.getById<Id, E>(id);
    if (fetchPolicy == FetchPolicy.storeOnly) {
      return Result.success(storeEntity);
    }

    if (fetchPolicy == FetchPolicy.storeFirst) {
      if (storeEntity != null) {
        return Result.success(storeEntity);
      }
    }

    final loadResult = await dataSourceHandler.loadAll();
    if (loadResult.isFailure) {
      return Result.failure(loadResult.failure);
    }

    var entity = loadResult.success.firstWhereOrNull((e) => e.id == id);
    if (entity == null) {
      notifyEntityNotFound(id);
      return Result.success(null);
    }

    notifyGetComplete(entity);
    return Result.success(entity);
  }

  @override
  Future<Result<E?, Exception>> findOne({
    FindOneOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw UnimplementedError(
        'Transaction is not supported in StorageRepository',
      );
    }

    final result = await query().findOne();
    return result;
  }

  @override
  Future<Result<int, Exception>> count({
    CountOptions? options,
  }) async {
    final result = await query().count();
    return result;
  }

  @override
  IRepositoryQuery<Id, E> query() {
    return StorageRepositoryQuery(this);
  }

  @override
  Future<Result<E, Exception>> save(
    E entity, {
    SaveOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw UnimplementedError(
        'Transaction is not supported in StorageRepository',
      );
    }

    final saveResult = await dataSourceHandler.save(entity);

    return saveResult.map(
      (success) async {
        notifySaveComplete(entity);
        return Result.success(entity);
      },
      (err) {
        return Result.failure(err);
      },
    );
  }

  @override
  Stream<Result<E?, Exception>> observeById(
    Id id, {
    ObserveByIdOptions? options,
  }) {
    throw UnimplementedError();
  }
}

/// A handler for a data source.
abstract class IDataSourceHandler<Id, E extends Entity<Id>> {
  late final Map<String, dynamic> Function(E entity) toJson;
  late final E Function(Map<String, dynamic> json) fromJson;
  late final String Function(Id id) idToString;

  Future<Result<void, Exception>> save(E entity);
  Future<Result<void, Exception>> saveAll(Iterable<E> entities);
  Future<Result<List<E>, Exception>> loadAll();
  Future<Result<void, Exception>> delete(Id id);
  Future<Result<void, Exception>> clear();
}

class InMemoryDataSourceHandler<Id, E extends Entity<Id>>
    extends IDataSourceHandler<Id, E> {
  final Map<Type, Map<Id, E>> _data = {};

  @override
  Future<Result<void, Exception>> delete(Id id) async {
    _data[E]!.remove(id);
    return Result.success(null);
  }

  @override
  Future<Result<List<E>, Exception>> loadAll() async {
    return Result.success(_data[E]!.values.toList());
  }

  @override
  Future<Result<void, Exception>> save(E entity) async {
    _data[E]![entity.id] = entity;
    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> clear() async {
    _data[E]!.clear();
    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> saveAll(Iterable<E> entities) async {
    for (var entity in entities) {
      await save(entity);
    }
    return Result.success(null);
  }
}

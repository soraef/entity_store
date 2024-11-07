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
    implements IRepository<Id, E> {
  StorageRepository({
    required this.dataSourceHandler,
    required this.controller,
  }) {
    dataSourceHandler.toJson = toJson;
    dataSourceHandler.fromJson = fromJson;
  }

  final IDataSourceHandler<Id, E> dataSourceHandler;

  @override
  final EntityStoreController controller;

  /// Synchronizes data with a remote data source if there are updates.
  Future<Result<void, Exception>> syncRemoteDataIfUpdated() async {
    return Result.ok(null);
  }

  @override
  Future<Result<E?, Exception>> upsert(
    Id id, {
    required E? Function() creater,
    required E? Function(E prev) updater,
    UpsertOptions? options,
  }) async {
    final skipSyncCheck = switch (options) {
      StorageUpsertOptions(skipSyncCheck: true) => true,
      _ => false,
    };

    if (!skipSyncCheck) {
      final syncResult = await syncRemoteDataIfUpdated();
      if (syncResult.isExcept) {
        return Result.except(syncResult.except);
      }
    }

    final findResult = await findById(id,
        options: const FindByIdOptions(fetchPolicy: FetchPolicy.storeOnly));
    if (findResult.isExcept) {
      return Result.except(findResult.except);
    }

    final newEntity =
        findResult.okOrNull == null ? creater() : updater(findResult.ok!);

    if (newEntity != null) {
      return save(newEntity);
    } else {
      return Result.ok(null);
    }
  }

  @override
  Future<Result<Id, Exception>> delete(
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
      (ok) {
        notifyDeleteComplete(id);
        return Result.ok(id);
      },
      (err) {
        return Result.except(err);
      },
    );
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

    final skipSyncCheck = switch (options) {
      StorageFindAllOptions(skipSyncCheck: true) => true,
      _ => false,
    };

    if (!skipSyncCheck) {
      final syncResult = await syncRemoteDataIfUpdated();
      if (syncResult.isExcept) {
        return Result.except(syncResult.except);
      }
    }

    return query().findAll();
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

    final skipSyncCheck = switch (options) {
      StorageFindByIdOptions(skipSyncCheck: true) => true,
      _ => false,
    };

    if (!skipSyncCheck) {
      final syncResult = await syncRemoteDataIfUpdated();
      if (syncResult.isExcept) {
        return Result.except(syncResult.except);
      }
    }

    options ??= const FindByIdOptions();

    final storeEntity = controller.getById<Id, E>(id);
    if (options.fetchPolicy == FetchPolicy.storeOnly) {
      return Result.ok(storeEntity);
    }

    if (options.fetchPolicy == FetchPolicy.storeFirst) {
      if (storeEntity != null) {
        return Result.ok(storeEntity);
      }
    }

    final loadResult = await dataSourceHandler.loadAll();
    return loadResult.map(
      (ok) {
        final entity = ok.firstWhereOrNull((e) => e.id == id);
        if (entity != null) {
          notifyGetComplete(entity);
        } else {
          notifyEntityNotFound(id);
        }
        return Result.ok(entity);
      },
      (err) {
        return Result.except(err);
      },
    );
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

    final skipSyncCheck = switch (options) {
      StorageFindOneOptions(skipSyncCheck: true) => true,
      _ => false,
    };

    if (!skipSyncCheck) {
      final syncResult = await syncRemoteDataIfUpdated();
      if (syncResult.isExcept) {
        return Result.except(syncResult.except);
      }
    }

    return query().findOne();
  }

  @override
  Future<Result<int, Exception>> count({
    CountOptions? options,
  }) async {
    final skipSyncCheck = switch (options) {
      StorageCountOptions(skipSyncCheck: true) => true,
      _ => false,
    };

    if (!skipSyncCheck) {
      final syncResult = await syncRemoteDataIfUpdated();
      if (syncResult.isExcept) {
        return Result.except(syncResult.except);
      }
    }

    return query().count();
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
      (ok) {
        notifySaveComplete(entity);
        return Result.ok(entity);
      },
      (err) {
        return Result.except(err);
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

  Future<Result<void, Exception>> save(E entity);
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
    return Result.ok(null);
  }

  @override
  Future<Result<List<E>, Exception>> loadAll() async {
    return Result.ok(_data[E]!.values.toList());
  }

  @override
  Future<Result<void, Exception>> save(E entity) async {
    _data[E]![entity.id] = entity;
    return Result.ok(null);
  }

  @override
  Future<Result<void, Exception>> clear() async {
    _data[E]!.clear();
    return Result.ok(null);
  }
}

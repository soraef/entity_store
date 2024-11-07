part of '../local_storage_repository.dart';

@Deprecated("Use StorageRepository instead.")
abstract class LocalStorageRepository<Id, E extends Entity<Id>>
    with EntityChangeNotifier<Id, E>
    implements IRepository<Id, E> {
  LocalStorageRepository(this.controller, this.localStorageHandler);

  @override
  final EntityStoreController controller;
  final ILocalStorageHandler localStorageHandler;

  late final LocalStorageEntityHander<Id, E> localStorageEntityHander =
      LocalStorageEntityHander<Id, E>(
    localStorageHandler,
    toJson,
    fromJson,
  );

  @override
  Future<Result<E?, Exception>> upsert(
    Id id, {
    required E? Function() creater,
    required E? Function(E prev) updater,
    UpsertOptions? options,
  }) async {
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
          'Transaction is not supported in LocalStorageRepository');
    }

    final deleteResult = await localStorageEntityHander.delete(id);

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
  }) {
    if (transaction != null) {
      throw UnimplementedError(
          'Transaction is not supported in LocalStorageRepository');
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
          'Transaction is not supported in LocalStorageRepository');
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

    final loadResult = await localStorageEntityHander.loadEntityList();
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
  }) {
    if (transaction != null) {
      throw UnimplementedError(
        'Transaction is not supported in LocalStorageRepository',
      );
    }

    return query().findOne();
  }

  @override
  Future<Result<int, Exception>> count({
    CountOptions? options,
  }) {
    return query().count();
  }

  @override
  IRepositoryQuery<Id, E> query() {
    return LocalStorageRepositoryQuery(this);
  }

  @override
  Future<Result<E, Exception>> save(
    E entity, {
    SaveOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw UnimplementedError(
        'Transaction is not supported in LocalStorageRepository',
      );
    }

    final saveResult = await localStorageEntityHander.save(entity);

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

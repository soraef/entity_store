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
  Future<E?> upsert(
    Id id, {
    required E? Function() creater,
    required E? Function(E prev) updater,
    UpsertOptions? options,
  }) async {
    final entity = await findById(
      id,
      options: StorageFindByIdOptions(),
    );

    final newEntity = entity == null ? creater() : updater(entity);

    if (newEntity != null) {
      await save(
        newEntity,
        options: StorageSaveOptions(),
      );
      return newEntity;
    } else {
      return null;
    }
  }

  @override
  Future<Id> deleteById(
    Id id, {
    DeleteOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw TransactionException(
        'Transaction is not supported in StorageRepository',
      );
    }

    try {
      await dataSourceHandler.delete(id);
      notifyDeleteComplete(id);
      return id;
    } catch (e) {
      throw EntityDeleteException(id, reason: e.toString());
    }
  }

  @override
  Future<E> delete(
    E entity, {
    DeleteOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw TransactionException(
        'Transaction is not supported in StorageRepository',
      );
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
      throw TransactionException(
        'Transaction is not supported in StorageRepository',
      );
    }

    return await query().findAll(
      options: options,
      transaction: transaction,
    );
  }

  @override
  Future<E?> findById(
    Id id, {
    FindByIdOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw TransactionException(
        'Transaction is not supported in StorageRepository',
      );
    }

    final fetchPolicy = FetchPolicyOptions.getFetchPolicy(options);

    final storeEntity = controller.getById<Id, E>(id);
    if (fetchPolicy == FetchPolicy.storeOnly) {
      return storeEntity;
    }

    if (fetchPolicy == FetchPolicy.storeFirst) {
      if (storeEntity != null) {
        return storeEntity;
      }
    }

    try {
      final entities = await dataSourceHandler.loadAll();
      var entity = entities.firstWhereOrNull((e) => e.id == id);
      if (entity == null) {
        notifyEntityNotFound(id);
        return null;
      }

      notifyGetComplete(entity);
      return entity;
    } catch (e) {
      throw DataSourceException(
          'Failed to load entity with id $id: ${e.toString()}');
    }
  }

  @override
  Future<E?> findOne({
    FindOneOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw TransactionException(
        'Transaction is not supported in StorageRepository',
      );
    }

    return await query().findOne(
      options: options,
      transaction: transaction,
    );
  }

  @override
  Future<int> count({
    CountOptions? options,
  }) async {
    return await query().count(options: options);
  }

  @override
  IRepositoryQuery<Id, E> query() {
    return StorageRepositoryQuery(this);
  }

  @override
  Future<E> save(
    E entity, {
    SaveOptions? options,
    TransactionContext? transaction,
  }) async {
    if (transaction != null) {
      throw TransactionException(
        'Transaction is not supported in StorageRepository',
      );
    }

    try {
      await dataSourceHandler.save(entity);
      notifySaveComplete(entity);
      return entity;
    } catch (e) {
      throw EntitySaveException(entity, reason: e.toString());
    }
  }

  @override
  Stream<E?> observeById(
    Id id, {
    ObserveByIdOptions? options,
  }) {
    throw UnimplementedError('observeById is not implemented');
  }
}

/// A handler for a data source.
abstract class IDataSourceHandler<Id, E extends Entity<Id>> {
  late final Map<String, dynamic> Function(E entity) toJson;
  late final E Function(Map<String, dynamic> json) fromJson;
  late final String Function(Id id) idToString;

  Future<void> save(E entity);
  Future<void> saveAll(Iterable<E> entities);
  Future<List<E>> loadAll();
  Future<void> delete(Id id);
  Future<void> clear();
}

class InMemoryDataSourceHandler<Id, E extends Entity<Id>>
    extends IDataSourceHandler<Id, E> {
  final Map<Type, Map<Id, E>> _data = {};

  @override
  Future<void> delete(Id id) async {
    _data[E]!.remove(id);
  }

  @override
  Future<List<E>> loadAll() async {
    return _data[E]!.values.toList();
  }

  @override
  Future<void> save(E entity) async {
    _data[E]![entity.id] = entity;
  }

  @override
  Future<void> clear() async {
    _data[E]!.clear();
  }

  @override
  Future<void> saveAll(Iterable<E> entities) async {
    for (var entity in entities) {
      await save(entity);
    }
  }
}

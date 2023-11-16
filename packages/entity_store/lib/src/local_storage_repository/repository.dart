part of '../local_storage_repository.dart';

abstract class LocalStorageRepository<Id, E extends Entity<Id>>
    with EntityChangeNotifier<Id, E>
    implements IRepository<Id, E> {
  LocalStorageRepository(this.controller, this.localStorageHandler);

  @override
  final EntityStoreController controller;
  final LocalStorageHandler localStorageHandler;

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
    ICreateOrUpdateOptions? options,
  }) async {
    final findResult = await findById(id);
    if (findResult.isErr) {
      return Result.err(findResult.err);
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
  Future<Result<Id, Exception>> delete(Id id, {IDeleteOptions? options}) async {
    final deleteResult = await localStorageEntityHander.delete(id);

    return deleteResult.map(
      (ok) {
        notifyDeleteComplete(id);
        return Result.ok(id);
      },
      (err) {
        return Result.err(err);
      },
    );
  }

  @override
  Future<Result<List<E>, Exception>> findAll() {
    return query().findAll();
  }

  @override
  Future<Result<E?, Exception>> findById(Id id, {IGetOptions? options}) async {
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
        return Result.err(err);
      },
    );
  }

  @override
  Future<Result<E?, Exception>> findOne() {
    return query().findOne();
  }

  @override
  Future<Result<int, Exception>> count() {
    return query().count();
  }

  @override
  IRepositoryQuery<Id, E> query() {
    return LocalStorageRepositoryQuery(this);
  }

  @override
  Future<Result<E, Exception>> save(E entity, {ISaveOptions? options}) async {
    final saveResult = await localStorageEntityHander.save(entity);

    return saveResult.map(
      (ok) {
        notifySaveComplete(entity);
        return Result.ok(entity);
      },
      (err) {
        return Result.err(err);
      },
    );
  }

  Map<String, dynamic> toJson(E entity);
  E fromJson(Map<String, dynamic> json);
}

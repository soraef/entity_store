part of '../../repository_interface.dart';

abstract class IRepository<Id, E extends Entity<Id>> {
  final EntityStoreController controller;
  IRepository(this.controller);

  Future<Result<E?, Exception>> findById(
    Id id, {
    IGetOptions? options,
  });

  Future<Result<List<E>, Exception>> findAll();

  Future<Result<E?, Exception>> findOne();

  Future<Result<int, Exception>> count();

  IRepositoryQuery<Id, E> query();

  Future<Result<E, Exception>> save(
    E entity, {
    ISaveOptions? options,
  });

  Future<Result<Id, Exception>> delete(
    Id id, {
    IDeleteOptions? options,
  });

  Future<Result<E?, Exception>> upsert(
    Id id, {
    required E? Function() creater,
    required E? Function(E prev) updater,
    ICreateOrUpdateOptions? options,
  });
}

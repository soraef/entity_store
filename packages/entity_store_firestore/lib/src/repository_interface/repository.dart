part of '../repository_interface.dart';

abstract class IRepository<Id, E extends Entity<Id>> {
  final EntityStoreController controller;
  IRepository(this.controller);

  Future<Result<E?, Exception>> findById(
    Id id, {
    IGetOptions? options,
  });

  Future<Result<List<E>, Exception>> findAll();

  IRepositoryQuery query();

  Future<Result<E, Exception>> save(
    E entity, {
    ISaveOptions? options,
  });

  Future<Result<Id, Exception>> delete(
    Id entity, {
    IDeleteOptions? options,
  });
}

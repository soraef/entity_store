part of '../in_memory_repository.dart';

abstract class InMemoryRepository<Id, E extends Entity<Id>>
    with EntityChangeNotifier<Id, E>
    implements IRepository<Id, E> {
  InMemoryRepository(this.controller);

  @override
  Future<Result<E, Exception>> save(
    E entity, {
    ISaveOptions? options,
  }) async {
    notifySaveComplete(entity);
    return Result.ok(entity);
  }

  @override
  Future<Result<List<E>, Exception>> findAll() async {
    return query().findAll();
  }

  @override
  Future<Result<Id, Exception>> delete(
    Id id, {
    IDeleteOptions? options,
  }) async {
    notifyDeleteComplete(id);
    return Result.ok(id);
  }

  @override
  Future<Result<E?, Exception>> findById(
    Id id, {
    IGetOptions? options,
  }) async {
    final entity = controller.getById<Id, E>(id);
    if (entity != null) {
      notifyGetComplete(entity);
    } else {
      notifyEntityNotFound(id);
    }
    return Result.ok(entity);
  }

  @override
  final EntityStoreController controller;

  @override
  IRepositoryQuery<Id, E> query() {
    return InMemoryRepositoryQuery(this);
  }

  Map<String, dynamic> toJson(E entity);
  E fromJson(Map<String, dynamic> json);
}

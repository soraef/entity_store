part of "../repository.dart";

class InMemoryRepository<Id, E extends Entity<Id>> extends IRepository<Id, E> {
  InMemoryRepository(super.controller);

  @override
  Future<Result<E, Exception>> save(
    E entity, {
    SaveOptions options = const SaveOptions(),
  }) async {
    controller.dispatch(SaveEvent<Id, E>.now(entity));
    return Result.ok(entity);
  }

  @override
  Future<Result<List<E>, Exception>> list(Query query) async {
    return Result.ok(controller.where<Id, E>().toList());
  }

  @override
  Future<Result<E, Exception>> delete(
    E entity, {
    DeleteOptions options = const DeleteOptions(),
  }) async {
    controller.dispatch(DeleteEvent<Id, E>.now(entity.id));
    return Result.ok(entity);
  }

  @override
  Future<Result<E?, Exception>> get(
    Id id, {
    GetOptions options = const GetOptions(),
  }) async {
    return Result.ok(controller.get(id));
  }
}

class InMemoryRepositoryFactory implements IRepositoryFactory {
  final EntityStoreController controller;

  InMemoryRepositoryFactory(this.controller);

  @override
  InMemoryRepositoryFactory fromSubCollection<Id, E extends Entity<Id>>(Id id) {
    return this;
  }

  @override
  InMemoryRepository<Id, E> getRepo<Id, E extends Entity<Id>>() {
    return InMemoryRepository<Id, E>(controller);
  }
}

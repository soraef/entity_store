part of "../repository.dart";

abstract class IRepositoryFactory {
  IRepositoryFactory fromSubCollection<Id, E extends Entity<Id>>(Id id);
  IRepository<Id, E> getRepo<Id, E extends Entity<Id>>();
}

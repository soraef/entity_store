part of '../repository_interface.dart';

abstract interface class CallbackRepository<Id, E extends Entity<Id>> {
  Future<Result<void, Exception>> onBeforeSave(E entity);

  Future<Result<void, Exception>> onBeforeDeleteById(Id id);

  Future<Result<void, Exception>> onBeforeDelete(E entity);

  Future<Result<void, Exception>> onBeforeFindById(Id id);

  Future<Result<void, Exception>> onBeforeFindAll(
    IRepositoryQuery<Id, E> query,
  );

  Future<Result<void, Exception>> onBeforeCount();

  Future<Result<void, Exception>> onBeforeFindOne(
    IRepositoryQuery<Id, E> query,
  );

  Future<Result<void, Exception>> onBeforeUpsert(Id id);

  Future<Result<E, Exception>> onLoadEntity(E entity);
}

abstract interface class BeforeCallbackOptions {
  bool get enableBefore;

  static bool getEnableBefore(Object? options) {
    return switch (options) {
      BeforeCallbackOptions(:final enableBefore) => enableBefore,
      _ => true,
    };
  }
}

abstract interface class LoadEntityCallbackOptions {
  bool get enableLoadEntity;

  static bool getEnableLoadEntity(Object? options) {
    return switch (options) {
      LoadEntityCallbackOptions(:final enableLoadEntity) => enableLoadEntity,
      _ => true,
    };
  }
}

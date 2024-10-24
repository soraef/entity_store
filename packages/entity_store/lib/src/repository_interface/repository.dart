part of '../repository_interface.dart';

/// An interface for a repository that handles CRUD operations for entities.
///
/// The `IRepository` interface provides methods for finding, saving, deleting, and querying entities.
/// It is a generic interface that takes an `Id` type parameter for the entity's identifier,
/// and an `E` type parameter for the entity itself, which must extend the `Entity` class.
///
/// The repository requires an `EntityStoreController` instance to be passed in its constructor.
/// This controller is responsible for managing the entity store and handling data operations.
///
/// Example usage:
/// ```dart
/// IRepository<int, User> userRepository = UserRepository(entityStoreController);
/// ```
abstract class IRepository<Id, E extends Entity<Id>> {
  final EntityStoreController controller;

  /// Creates a new instance of the repository with the specified `controller`.
  IRepository(this.controller);

  /// Finds an entity by its `id`.
  ///
  /// Returns a `Result` object that contains the found entity or an exception if an error occurs.
  /// An optional `options` parameter can be provided to customize the query behavior.
  Future<Result<E?, Exception>> findById(
    Id id, {
    FindByIdOptions? options,
    ITransactionContext? transaction,
  });

  /// Finds all entities of type `E`.
  ///
  /// Returns a `Result` object that contains a list of entities or an exception if an error occurs.
  Future<Result<List<E>, Exception>> findAll({
    FindAllOptions? options,
    ITransactionContext? transaction,
  });

  /// Finds a single entity of type `E`.
  ///
  /// Returns a `Result` object that contains the found entity or an exception if an error occurs.
  Future<Result<E?, Exception>> findOne({
    FindOneOptions? options,
    ITransactionContext? transaction,
  });

  /// Counts the number of entities of type `E`.
  ///
  /// Returns a `Result` object that contains the count or an exception if an error occurs.
  Future<Result<int, Exception>> count();

  /// Creates a query object for querying entities of type `E`.
  ///
  /// Returns an `IRepositoryQuery` object that can be used to build and execute queries.
  IRepositoryQuery<Id, E> query();

  /// Saves an entity of type `E`.
  ///
  /// Returns a `Result` object that contains the saved entity or an exception if an error occurs.
  /// An optional `options` parameter can be provided to customize the save behavior.
  Future<Result<E, Exception>> save(
    E entity, {
    SaveOptions? options,
    ITransactionContext? transaction,
  });

  /// Deletes an entity by its `id`.
  ///
  /// Returns a `Result` object that contains the deleted entity's `id` or an exception if an error occurs.
  /// An optional `options` parameter can be provided to customize the delete behavior.
  Future<Result<Id, Exception>> delete(
    Id id, {
    DeleteOptions? options,
    ITransactionContext? transaction,
  });

  /// Upserts an entity by its `id`.
  ///
  /// If an entity with the specified `id` exists, it will be updated using the `updater` function.
  /// If no entity with the specified `id` exists, a new entity will be created using the `creater` function.
  ///
  /// Returns a `Result` object that contains the upserted entity or an exception if an error occurs.
  /// An optional `options` parameter can be provided to customize the upsert behavior.
  Future<Result<E?, Exception>> upsert(
    Id id, {
    required E? Function() creater,
    required E? Function(E prev) updater,
    UpsertOptions? options,
  });

  Stream<Result<E?, Exception>> observeById(
    Id id, {
    ObserveByIdOptions? options,
  });

  Map<String, dynamic> toJson(E entity);
  E fromJson(Map<String, dynamic> json);
}

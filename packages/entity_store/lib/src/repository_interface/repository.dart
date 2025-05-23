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
abstract interface class Repository<Id, E extends Entity<Id>> {
  // final EntityStoreController controller;

  // /// Creates a new instance of the repository with the specified `controller`.
  // IRepository(this.controller);

  /// Finds an entity by its `id`.
  ///
  /// Returns the found entity or null if not found.
  /// Throws a [RepositoryException] if an error occurs.
  /// An optional `options` parameter can be provided to customize the query behavior.
  Future<E?> findById(
    Id id, {
    FindByIdOptions? options,
    TransactionContext? transaction,
  });

  /// Finds all entities of type `E`.
  ///
  /// Returns a list of entities.
  /// Throws a [RepositoryException] if an error occurs.
  Future<List<E>> findAll({
    FindAllOptions? options,
    TransactionContext? transaction,
  });

  /// Finds a single entity of type `E`.
  ///
  /// Returns the found entity or null if not found.
  /// Throws a [RepositoryException] if an error occurs.
  Future<E?> findOne({
    FindOneOptions? options,
    TransactionContext? transaction,
  });

  /// Counts the number of entities of type `E`.
  ///
  /// Returns the count.
  /// Throws a [RepositoryException] if an error occurs.
  Future<int> count({
    CountOptions? options,
  });

  /// Creates a query object for querying entities of type `E`.
  ///
  /// Returns an `IRepositoryQuery` object that can be used to build and execute queries.
  IRepositoryQuery<Id, E> query();

  /// Saves an entity of type `E`.
  ///
  /// Returns the saved entity.
  /// Throws a [RepositoryException] if an error occurs.
  /// An optional `options` parameter can be provided to customize the save behavior.
  Future<E> save(
    E entity, {
    SaveOptions? options,
    TransactionContext? transaction,
  });

  /// Deletes an entity by its `id`.
  ///
  /// Returns the deleted entity's `id`.
  /// Throws a [RepositoryException] if an error occurs.
  /// An optional `options` parameter can be provided to customize the delete behavior.
  Future<Id> deleteById(
    Id id, {
    DeleteOptions? options,
    TransactionContext? transaction,
  });

  /// Deletes an entity.
  ///
  /// Returns the deleted entity.
  /// Throws a [RepositoryException] if an error occurs.
  /// An optional `options` parameter can be provided to customize the delete behavior.
  Future<E> delete(
    E entity, {
    DeleteOptions? options,
    TransactionContext? transaction,
  });

  /// Upserts an entity by its `id`.
  ///
  /// If an entity with the specified `id` exists, it will be updated using the `updater` function.
  /// If no entity with the specified `id` exists, a new entity will be created using the `creater` function.
  ///
  /// Returns the upserted entity or null if both create and update returned null.
  /// Throws a [RepositoryException] if an error occurs.
  /// An optional `options` parameter can be provided to customize the upsert behavior.
  Future<E?> upsert(
    Id id, {
    required E? Function() creater,
    required E? Function(E prev) updater,
    UpsertOptions? options,
  });

  /// Observes an entity by its `id`.
  ///
  /// Returns a stream of the entity. The stream will emit whenever the entity changes.
  /// Throws a [RepositoryException] if an error occurs.
  Stream<E?> observeById(
    Id id, {
    ObserveByIdOptions? options,
  });
}

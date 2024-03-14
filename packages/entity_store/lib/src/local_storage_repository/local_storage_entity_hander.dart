part of '../local_storage_repository.dart';

/// A handler for storing and retrieving entities in local storage.
///
/// This class provides methods for loading, saving, and deleting entities
/// using a specified local storage handler. It supports converting entities
/// to JSON and vice versa using the provided `toJson` and `fromJson` functions.
///
/// The `LocalStorageEntityHander` class is generic, with two type parameters:
/// - `Id`: The type of the entity's identifier.
/// - `E`: The type of the entity, which must extend the `Entity` class.
///
/// Example usage:
/// ```dart
/// final handler = LocalStorageEntityHander<MyId, MyEntity>(
///   localStorageHandler,
///   (entity) => entity.toJson(),
///   (json) => MyEntity.fromJson(json),
/// );
///
/// final result = await handler.loadEntityList();
/// if (result.isOk) {
///   final entities = result.ok;
///   // Do something with the loaded entities...
/// } else {
///   final error = result.err;
///   // Handle the error...
/// }
/// ```
class LocalStorageEntityHander<Id, E extends Entity<Id>> {
  final ILocalStorageHandler localStorageHandler;
  LocalStorageEntityHander(
    this.localStorageHandler,
    this.toJson,
    this.fromJson,
  );

  /// Loads a list of entities from the local storage.
  /// Returns a [Result] object containing either a list of entities or an exception.
  /// If the local storage does not contain the entity list, an empty list is returned.
  /// If there is an error during the loading process, the exception is returned.
  Future<Result<List<E>, Exception>> loadEntityList({
    LocalStorageTransaction? transaction,
  }) async {
    String? entityListJsonString;

    if (transaction != null) {
      entityListJsonString = await transaction.get(_getEntityListKey());
    } else {
      final entityListResult =
          await localStorageHandler.load(_getEntityListKey());
      if (entityListResult.isErr) {
        return Result.err(entityListResult.err);
      }
      entityListJsonString = entityListResult.ok;
    }

    if (entityListJsonString == null) {
      return Result.ok(<E>[]);
    }

    try {
      return Result.ok((jsonDecode(entityListJsonString) as List<dynamic>)
          .map((e) => fromJson(e))
          .toList());
    } catch (e) {
      return Result.ok(<E>[]);
    }
  }

  /// Saves the given entity to the local storage.
  /// Returns a [Result] indicating success or failure.
  /// If the current list of entities cannot be loaded, returns an error result.
  /// Otherwise, updates the list by replacing the entity with the same ID,
  /// or adds the entity if it doesn't exist in the list.
  /// Finally, encodes the updated list to JSON and saves it to the local storage.
  /// Returns the result of the save operation.
  Future<Result<void, Exception>> save(
    E entity, {
    LocalStorageTransaction? transaction,
  }) async {
    final currentListResult = await loadEntityList();
    if (currentListResult.isErr) {
      return Result.err(currentListResult.err);
    }

    final currentList = currentListResult.ok;
    final newList = <E>[
      ...currentList.where((e) => e.id != entity.id),
      entity,
    ];

    try {
      final jsonString = jsonEncode(newList.map((e) => toJson(e)).toList());
      if (transaction != null) {
        await transaction.put(_getEntityListKey(), jsonString);
        return Result.ok(null);
      } else {
        final saveResult =
            await localStorageHandler.save(_getEntityListKey(), jsonString);
        return saveResult;
      }
    } on Exception catch (e) {
      return Result.err(e);
    }
  }

  /// Deletes an entity with the specified [id] from the local storage.
  /// Returns a [Result] indicating success or failure.
  /// If the current entity list cannot be loaded, returns an error [Result].
  /// If the entity is successfully deleted and saved to the local storage, returns a success [Result].
  /// If an exception occurs during the deletion or saving process, returns an error [Result] with the exception.
  Future<Result<void, Exception>> delete(
    Id id, {
    LocalStorageTransaction? transaction,
  }) async {
    final currentListResult = await loadEntityList();
    if (currentListResult.isErr) {
      return Result.err(currentListResult.err);
    }

    final currentList = currentListResult.ok;
    final newList = <E>[
      ...currentList.where((e) => e.id != id),
    ];

    try {
      final jsonString = jsonEncode(newList.map((e) => toJson(e)).toList());
      if (transaction != null) {
        await transaction.put(_getEntityListKey(), jsonString);
        return Result.ok(null);
      } else {
        final saveResult =
            await localStorageHandler.save(_getEntityListKey(), jsonString);
        return saveResult;
      }
    } on Exception catch (e) {
      return Result.err(e);
    }
  }

  String _getEntityListKey() {
    return E.toString();
  }

  final Map<String, dynamic> Function(E entity) toJson;
  final E Function(Map<String, dynamic> json) fromJson;
}

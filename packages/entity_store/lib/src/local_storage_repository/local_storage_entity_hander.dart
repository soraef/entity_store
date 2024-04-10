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
  Future<Result<List<E>, Exception>> loadEntityList() async {
    final entityIndexResult =
        await localStorageHandler.load(_getEntityIndexKey());
    if (entityIndexResult.isErr) {
      return Result.err(entityIndexResult.err);
    }

    final entityIndexJsonString = entityIndexResult.ok;
    if (entityIndexJsonString == null) {
      return Result.ok(<E>[]);
    }

    final entityIdList = List<String>.from(jsonDecode(entityIndexJsonString));
    final entityList = <E>[];

    for (final entityId in entityIdList) {
      final entityResult =
          await localStorageHandler.load(_getEntityKey(entityId));
      if (entityResult.isOk) {
        final entityJsonString = entityResult.ok;
        if (entityJsonString != null) {
          try {
            final entity = fromJson(jsonDecode(entityJsonString));
            entityList.add(entity);
          } catch (e) {
            // Ignore decoding errors and continue with other entities
          }
        }
      }
    }

    return Result.ok(entityList);
  }

  /// Saves the given entity to the local storage.
  /// Returns a [Result] indicating success or failure.
  /// If the current list of entities cannot be loaded, returns an error result.
  /// Otherwise, updates the list by replacing the entity with the same ID,
  /// or adds the entity if it doesn't exist in the list.
  /// Finally, encodes the updated list to JSON and saves it to the local storage.
  /// Returns the result of the save operation.
  Future<Result<void, Exception>> save(E entity) async {
    try {
      final entityJsonString = jsonEncode(toJson(entity));
      final saveResult = await localStorageHandler.save(
        _getEntityKey(entity.id.toString()),
        entityJsonString,
      );

      if (saveResult.isOk) {
        final indexResult = await _updateEntityIndex(entity.id.toString());
        return indexResult;
      }

      return saveResult;
    } on Exception catch (e) {
      return Result.err(e);
    }
  }

  /// Deletes an entity with the specified [id] from the local storage.
  /// Returns a [Result] indicating success or failure.
  /// If the current entity list cannot be loaded, returns an error [Result].
  /// If the entity is successfully deleted and saved to the local storage, returns a success [Result].
  /// If an exception occurs during the deletion or saving process, returns an error [Result] with the exception.
  Future<Result<void, Exception>> delete(Id id) async {
    try {
      final deleteResult =
          await localStorageHandler.delete(_getEntityKey(id.toString()));

      if (deleteResult.isOk) {
        final indexResult = await _removeFromEntityIndex(id.toString());
        return indexResult;
      }

      return deleteResult;
    } on Exception catch (e) {
      return Result.err(e);
    }
  }

  Future<Result<void, Exception>> _updateEntityIndex(String entityId) async {
    final entityIndexResult =
        await localStorageHandler.load(_getEntityIndexKey());
    final entityIndexList =
        entityIndexResult.isOk && entityIndexResult.ok != null
            ? List<String>.from(jsonDecode(entityIndexResult.ok!))
            : <String>[];

    if (!entityIndexList.contains(entityId)) {
      entityIndexList.add(entityId);
      final entityIndexJsonString = jsonEncode(entityIndexList);
      return await localStorageHandler.save(
          _getEntityIndexKey(), entityIndexJsonString);
    }

    return Result.ok(null);
  }

  Future<Result<void, Exception>> _removeFromEntityIndex(
    String entityId,
  ) async {
    final entityIndexResult =
        await localStorageHandler.load(_getEntityIndexKey());
    final entityIndexList =
        entityIndexResult.isOk && entityIndexResult.ok != null
            ? List<String>.from(jsonDecode(entityIndexResult.ok!))
            : <String>[];

    entityIndexList.remove(entityId);
    final entityIndexJsonString = jsonEncode(entityIndexList);
    return await localStorageHandler.save(
      _getEntityIndexKey(),
      entityIndexJsonString,
    );
  }

  String _getEntityIndexKey() {
    return '${E.toString()}:index';
  }

  String _getEntityKey(String id) {
    return '${E.toString()}:$id';
  }

  final Map<String, dynamic> Function(E entity) toJson;
  final E Function(Map<String, dynamic> json) fromJson;
}

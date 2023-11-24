part of '../../local_storage_repository.dart';

/// An abstract class representing a local storage handler.
///
/// This class defines methods for saving, loading, deleting, and clearing data in local storage.
abstract class ILocalStorageHandler {
  /// Saves the given [value] with the specified [key] in local storage.
  ///
  /// Returns a [Future] that completes with a [Result] indicating success or failure.
  Future<Result<void, Exception>> save(String key, String value);

  /// Loads the value associated with the specified [key] from local storage.
  ///
  /// Returns a [Future] that completes with a [Result] containing the loaded value or an error.
  Future<Result<String?, Exception>> load(String key);

  /// Deletes the value associated with the specified [key] from local storage.
  ///
  /// Returns a [Future] that completes with a [Result] indicating success or failure.
  Future<Result<void, Exception>> delete(String key);

  /// Clears all data stored in local storage.
  ///
  /// Returns a [Future] that completes with a [Result] indicating success or failure.
  Future<Result<void, Exception>> clear();
}

/// A storage handler implementation that stores data in memory.
class InMemoryStorageHandler extends ILocalStorageHandler {
  final Map<String, String> _storage = {};

  /// Clears all the data stored in memory.
  ///
  /// Returns a [Result] indicating the success or failure of the operation.
  @override
  Future<Result<void, Exception>> clear() {
    _storage.clear();
    return Future.value(Result.ok(null));
  }

  /// Deletes the data associated with the given [key] from memory.
  ///
  /// Returns a [Result] indicating the success or failure of the operation.
  @override
  Future<Result<void, Exception>> delete(String key) {
    _storage.remove(key);
    return Future.value(Result.ok(null));
  }

  /// Loads the data associated with the given [key] from memory.
  ///
  /// Returns a [Result] containing the loaded data or an exception if the data is not found.
  @override
  Future<Result<String?, Exception>> load(String key) {
    return Future.value(Result.ok(_storage[key]));
  }

  /// Saves the given [value] associated with the given [key] in memory.
  ///
  /// Returns a [Result] indicating the success or failure of the operation.
  @override
  Future<Result<void, Exception>> save(String key, String value) {
    _storage[key] = value;
    return Future.value(Result.ok(null));
  }
}

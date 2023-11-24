part of '../../local_storage_repository.dart';

abstract class LocalStorageHandler {
  Future<Result<void, Exception>> save(String key, String value);
  Future<Result<String?, Exception>> load(String key);
  Future<Result<void, Exception>> delete(String key);
  Future<Result<void, Exception>> clear();
}

class InMemoryStorageHandler extends LocalStorageHandler {
  final Map<String, String> _storage = {};

  @override
  Future<Result<void, Exception>> clear() {
    _storage.clear();
    return Future.value(Result.ok(null));
  }

  @override
  Future<Result<void, Exception>> delete(String key) {
    _storage.remove(key);
    return Future.value(Result.ok(null));
  }

  @override
  Future<Result<String?, Exception>> load(String key) {
    return Future.value(Result.ok(_storage[key]));
  }

  @override
  Future<Result<void, Exception>> save(String key, String value) {
    _storage[key] = value;
    return Future.value(Result.ok(null));
  }
}

part of '../local_storage_repository.dart';

abstract class LocalStorageHandler {
  Future<Result<void, Exception>> save(String key, String value);
  Future<Result<String?, Exception>> load(String key);
  Future<Result<void, Exception>> delete(String key);
  Future<Result<void, Exception>> clear();
}

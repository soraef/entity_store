part of "../local_storage_repository.dart";

class LocalStorageTransaction implements ITransaction {
  final ILocalStorageHandler _localStorageHandler;
  final Map<String, String?> _pendingChanges = {};

  LocalStorageTransaction(this._localStorageHandler);

  Future<void> put(String key, String? value) async {
    _pendingChanges[key] = value;
  }

  Future<String?> get(String key) async {
    if (_pendingChanges.containsKey(key)) {
      return _pendingChanges[key];
    } else {
      var result = await _localStorageHandler.load(key);
      if (result.isErr) {
        throw result.err; // またはエラー処理
      }
      return result.ok;
    }
  }

  @override
  Future<void> commit() async {
    for (var entry in _pendingChanges.entries) {
      if (entry.value == null) {
        await _localStorageHandler.delete(entry.key);
      } else {
        await _localStorageHandler.save(entry.key, entry.value!);
      }
    }
  }

  @override
  Future<void> rollback() async {
    _pendingChanges.clear();
  }
}

class LocalStorageTransactionRunner implements ITransactionRunner {
  final InMemoryStorageHandler _handler;
  LocalStorageTransactionRunner(this._handler);

  @override
  Future<T> run<T>(
    Future<Result<T, Object>> Function(LocalStorageTransaction transaction)
        operation,
  ) async {
    final transaction = LocalStorageTransaction(_handler);
    try {
      final result = await operation(transaction);
      if (result.isErr) {
        await transaction.rollback();
        return Future.error(result.err);
      }
      await transaction.commit();
      return result.ok;
    } catch (e) {
      await transaction.rollback();
      rethrow;
    }
  }
}

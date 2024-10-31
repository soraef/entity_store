part of '../repository_interface.dart';

class TransactionOptions {}

abstract class ITransaction<TTransactionContext extends ITransactionContext> {
  final EntityStoreController controller;

  ITransaction({
    required this.controller,
  });

  /// Run transaction.
  ///
  /// run((context) {
  ///   final user = await userRepo.findById(1, transaction: context);
  ///   user.name = 'new name';
  ///   userRepo.save(user, transaction: context);
  /// })
  Future<Result<T, Exception>> run<T>(
    Future<T> Function(TTransactionContext context) fn, {
    TransactionOptions? options,
  }) async {
    final result = await handleTransaction(fn, options);
    if (result.isExcept) {
      throw result.except.toExcept();
    }

    final context = result.ok.$2;
    context.complete();

    return result.ok.$1.toOk();
  }

  Future<Result<(T, TTransactionContext), Exception>> handleTransaction<T>(
    Future<T> Function(TTransactionContext context) fn,
    TransactionOptions? options,
  );
}

abstract class ITransactionContext {
  ITransactionContext();

  /// トランザクションが成功された場合に実行する関数のリスト
  final List<Function()> _onCommitFunctions = [];

  void addOnCommitFunction(Function() fn) {
    _onCommitFunctions.add(fn);
  }

  void complete() {
    for (var fn in _onCommitFunctions) {
      fn();
    }
  }

  Future<void> rollback();
}

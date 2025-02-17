part of '../repository_interface.dart';

class TransactionOptions {}

abstract class TransactionRunner<
    TTransactionContext extends TransactionContext> {
  final EntityStoreController controller;

  TransactionRunner({
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
    if (result.isFailure) {
      return result.failure.toFailure();
    }

    final context = result.success.$2;
    context.complete();

    return result.success.$1.toSuccess();
  }

  Future<Result<(T, TTransactionContext), Exception>> handleTransaction<T>(
    Future<T> Function(TTransactionContext context) fn,
    TransactionOptions? options,
  );
}

abstract class TransactionContext {
  TransactionContext();

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

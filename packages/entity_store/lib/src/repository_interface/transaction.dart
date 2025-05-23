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
  Future<T> run<T>(
    Future<T> Function(TTransactionContext context) fn, {
    TransactionOptions? options,
  }) async {
    final (result, context) = await handleTransaction(fn, options);
    context.complete();
    return result;
  }

  /// ハンドルトランザクション
  ///
  /// トランザクションを処理し、結果とトランザクションコンテキストを返す
  Future<(T, TTransactionContext)> handleTransaction<T>(
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

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

  /// Handles the transaction execution.
  ///
  /// Processes the transaction and returns the result along with the transaction context.
  Future<(T, TTransactionContext)> handleTransaction<T>(
    Future<T> Function(TTransactionContext context) fn,
    TransactionOptions? options,
  );
}

abstract class TransactionContext {
  TransactionContext();

  /// List of functions to execute when the transaction commits successfully.
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

part of '../repository_interface.dart';

abstract class ITransaction<TTransactionContext extends ITransactionContext> {
  Future<T> run<T>(Future<T> Function(TTransactionContext context) fn);
}

abstract class ITransactionContext {
  Future<void> commit();
  Future<void> rollback();
}

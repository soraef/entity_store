part of '../repository_interface.dart';

abstract class ITransactionRunner {
  Future<T> run<T>(
      Future<Result<T, Object>> Function(ITransaction transaction) operation);
}

abstract class ITransaction {
  Future<void> commit();
  Future<void> rollback();
}

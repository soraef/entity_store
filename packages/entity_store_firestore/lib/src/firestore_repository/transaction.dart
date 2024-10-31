part of '../firestore_repository.dart';

class FirestoreTransactionContext extends ITransactionContext {
  final Transaction value;

  FirestoreTransactionContext(this.value);

  @override
  Future<void> rollback() {
    throw UnimplementedError();
  }
}

class FirestoreTransaction extends ITransaction<FirestoreTransactionContext> {
  final FirebaseFirestore instance;

  FirestoreTransaction({
    required super.controller,
    required this.instance,
  });

  @override
  Future<Result<(T, FirestoreTransactionContext), Exception>>
      handleTransaction<T>(
    Future<T> Function(FirestoreTransactionContext context) fn,
  ) async {
    try {
      return await instance.runTransaction(
        (transaction) async {
          final context = FirestoreTransactionContext(transaction);
          final result = await fn(context);
          return (result, context).toOk();
        },
      );
    } catch (e) {
      if (e is Exception) {
        return Result.except(e);
      }
      return Result.except(Exception(e));
    }
  }
}

part of '../firestore_repository.dart';

final class FirestoreTransactionOptions extends TransactionOptions {
  final Duration? timeout;
  final int? maxAttempts;

  FirestoreTransactionOptions({this.timeout, this.maxAttempts});
}

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
    TransactionOptions? options,
  ) async {
    FirestoreTransactionOptions? firestoreOptions;
    if (options != null && options is! FirestoreTransactionOptions) {
      throw ArgumentError("options must be FirestoreTransactionOptions");
    } else if (options != null) {
      firestoreOptions = options as FirestoreTransactionOptions;
    }

    try {
      return await instance.runTransaction(
        (transaction) async {
          final context = FirestoreTransactionContext(transaction);
          final result = await fn(context);
          return (result, context).toOk();
        },
        timeout: firestoreOptions?.timeout ?? const Duration(seconds: 30),
        maxAttempts: firestoreOptions?.maxAttempts ?? 5,
      );
    } catch (e) {
      if (e is Exception) {
        return Result.except(e);
      }
      return Result.except(Exception(e));
    }
  }
}

part of '../firestore_repository.dart';

class FirestoreTransactionContext implements ITransactionContext {
  final Transaction value;

  FirestoreTransactionContext(this.value);

  @override
  Future<void> commit() async {}

  @override
  Future<void> rollback() async {}
}

class FirestoreTransaction
    implements ITransaction<FirestoreTransactionContext> {
  final FirebaseFirestore instance;
  final EntityStoreController controller;

  FirestoreTransaction({
    required this.instance,
    required this.controller,
  });

  @override
  Future<T> run<T>(
    Future<T> Function(FirestoreTransactionContext context) fn,
  ) async {
    return instance.runTransaction(
      (transaction) async {
        final context = FirestoreTransactionContext(transaction);
        return fn(context);
      },
    );
  }
}

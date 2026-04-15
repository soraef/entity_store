import 'package:drift/drift.dart';
import 'package:entity_store/entity_store.dart';

class DriftTransactionContext extends TransactionContext {
  final GeneratedDatabase db;

  DriftTransactionContext(this.db);

  @override
  Future<void> rollback() async {
    throw Exception('Transaction rollback requested');
  }
}

class DriftTransactionRunner extends TransactionRunner<DriftTransactionContext> {
  final GeneratedDatabase db;

  DriftTransactionRunner({
    required this.db,
    required super.controller,
  });

  @override
  Future<(T, DriftTransactionContext)> handleTransaction<T>(
    Future<T> Function(DriftTransactionContext context) fn,
    TransactionOptions? options,
  ) async {
    late T result;
    final context = DriftTransactionContext(db);
    await db.transaction(() async {
      result = await fn(context);
    });
    return (result, context);
  }
}

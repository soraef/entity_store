import 'package:entity_store/entity_store.dart';
import 'package:isar_community/isar.dart';

class IsarTransactionContext extends TransactionContext {
  final Isar isar;
  final bool isWriteTransaction;

  IsarTransactionContext({
    required this.isar,
    this.isWriteTransaction = true,
  });

  Future<T> execute<T>(Future<T> Function() action) async {
    if (isWriteTransaction) {
      return await isar.writeTxn(() async {
        return await action();
      });
    } else {
      return await isar.txn(() async {
        return await action();
      });
    }
  }

  @override
  Future<void> rollback() async {
    // Isar transactions are automatically rolled back on error
    // This method is here for compatibility with the TransactionContext interface
    throw Exception('Transaction rollback requested');
  }
}

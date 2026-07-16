import '../../../core/data/app_database.dart';
import '../../../core/entities/transaction.dart';

abstract class TransactionLocalDataSource {
  Future<List<Transaction>> getAll();
  Future<Transaction?> getById(String id);
  Future<Transaction> add(Transaction transaction);
  Future<Transaction> update(Transaction transaction);
  Future<void> delete(String id);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final AppDatabase db;

  TransactionLocalDataSourceImpl(this.db);

  @override
  Future<List<Transaction>> getAll() async {
    // Simulate async source latency.
    await Future.delayed(const Duration(milliseconds: 350));
    final list = List<Transaction>.from(db.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<Transaction?> getById(String id) async {
    for (final t in db.transactions) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  Future<Transaction> add(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 200));
    db.transactions.insert(0, transaction);
    return transaction;
  }

  @override
  Future<Transaction> update(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = db.transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      db.transactions[index] = transaction;
    }
    return transaction;
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    db.transactions.removeWhere((t) => t.id == id);
  }
}

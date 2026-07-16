import '../../../core/entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAll();
  Future<Transaction?> getById(String id);
  Future<Transaction> add(Transaction transaction);
  Future<Transaction> update(Transaction transaction);
  Future<void> delete(String id);
}

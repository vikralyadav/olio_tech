import '../../../core/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource dataSource;

  TransactionRepositoryImpl(this.dataSource);

  @override
  Future<List<Transaction>> getAll() => dataSource.getAll();

  @override
  Future<Transaction?> getById(String id) => dataSource.getById(id);

  @override
  Future<Transaction> add(Transaction transaction) => dataSource.add(transaction);

  @override
  Future<Transaction> update(Transaction transaction) =>
      dataSource.update(transaction);

  @override
  Future<void> delete(String id) => dataSource.delete(id);
}

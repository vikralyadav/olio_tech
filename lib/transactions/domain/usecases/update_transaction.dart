import '../../../core/entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository repository;
  UpdateTransaction(this.repository);

  Future<Transaction> call(Transaction transaction) =>
      repository.update(transaction);
}

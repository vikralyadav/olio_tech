import '../../../core/entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransaction {
  final TransactionRepository repository;
  AddTransaction(this.repository);

  Future<Transaction> call(Transaction transaction) =>
      repository.add(transaction);
}

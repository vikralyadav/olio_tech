import '../../../core/data/app_database.dart';
import '../../../core/entities/budget.dart';
import '../../../core/entities/transaction.dart';

abstract class BudgetLocalDataSource {
  Future<List<Budget>> getAll();
  Future<Budget> add(Budget budget);
  Future<Budget> update(Budget budget);
  Future<void> delete(String id);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final AppDatabase db;

  BudgetLocalDataSourceImpl(this.db);

  /// Recomputes each budget's [Budget.spent] from the current month's
  /// expense transactions so budgets stay in sync with transaction CRUD.
  @override
  Future<List<Budget>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return db.budgets.map((b) {
      final spent = db.transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.categoryId == b.categoryId &&
              t.date.year == now.year &&
              t.date.month == now.month)
          .fold(0.0, (s, t) => s + t.amount);
      return b.copyWith(spent: double.parse(spent.toStringAsFixed(2)));
    }).toList();
  }

  @override
  Future<Budget> add(Budget budget) async {
    await Future.delayed(const Duration(milliseconds: 200));
    db.budgets.add(budget);
    return budget;
  }

  @override
  Future<Budget> update(Budget budget) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final i = db.budgets.indexWhere((b) => b.id == budget.id);
    if (i != -1) db.budgets[i] = budget;
    return budget;
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    db.budgets.removeWhere((b) => b.id == id);
  }
}

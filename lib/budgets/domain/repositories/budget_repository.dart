import '../../../core/entities/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getAll();
  Future<Budget> add(Budget budget);
  Future<Budget> update(Budget budget);
  Future<void> delete(String id);
}

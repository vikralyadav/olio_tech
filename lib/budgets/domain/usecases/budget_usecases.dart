import '../../../core/entities/budget.dart';
import '../repositories/budget_repository.dart';

class GetBudgets {
  final BudgetRepository repository;
  GetBudgets(this.repository);
  Future<List<Budget>> call() => repository.getAll();
}

class AddBudget {
  final BudgetRepository repository;
  AddBudget(this.repository);
  Future<Budget> call(Budget budget) => repository.add(budget);
}

class UpdateBudget {
  final BudgetRepository repository;
  UpdateBudget(this.repository);
  Future<Budget> call(Budget budget) => repository.update(budget);
}

class DeleteBudget {
  final BudgetRepository repository;
  DeleteBudget(this.repository);
  Future<void> call(String id) => repository.delete(id);
}

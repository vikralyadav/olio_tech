import '../../../core/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_data_source.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource dataSource;

  BudgetRepositoryImpl(this.dataSource);

  @override
  Future<List<Budget>> getAll() => dataSource.getAll();

  @override
  Future<Budget> add(Budget budget) => dataSource.add(budget);

  @override
  Future<Budget> update(Budget budget) => dataSource.update(budget);

  @override
  Future<void> delete(String id) => dataSource.delete(id);
}

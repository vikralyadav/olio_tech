import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../budgets/domain/repositories/budget_repository.dart';
import '../../../core/entities/transaction.dart';
import '../../../core/utils/finance_calculator.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import 'dashboard_state.dart';

/// Aggregates data from the transaction & budget repositories (reuse).
class DashboardCubit extends Cubit<DashboardState> {
  final TransactionRepository transactionRepository;
  final BudgetRepository budgetRepository;

  DashboardCubit({
    required this.transactionRepository,
    required this.budgetRepository,
  }) : super(const DashboardState());

  Future<void> load() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final txns = await transactionRepository.getAll();
      final budgets = await budgetRepository.getAll();
      final now = DateTime.now();

      final income = FinanceCalculator.monthlyIncome(txns, now);
      final expense = FinanceCalculator.monthlyExpense(txns, now);
      final breakdown =
          FinanceCalculator.categoryBreakdown(txns, now.year, now.month);

      final sortedBudgets = List.of(budgets)
        ..sort((a, b) => b.percentage.compareTo(a.percentage));

      emit(state.copyWith(
        status: DashboardStatus.loaded,
        totalBalance: FinanceCalculator.balance(txns),
        monthlyIncome: income,
        monthlyExpense: expense,
        savingsRate: FinanceCalculator.savingsRate(income, expense),
        recent: txns.take(6).toList(),
        spendingTrend: FinanceCalculator.monthlyTrend(
            txns, TransactionType.expense,
            months: 6),
        categoryBreakdown: breakdown,
        topBudgets: sortedBudgets.take(4).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(
          status: DashboardStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> refresh() => load();
}

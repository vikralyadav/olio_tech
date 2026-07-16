import 'package:equatable/equatable.dart';

import '../../../core/entities/budget.dart';
import '../../../core/entities/transaction.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double savingsRate;
  final List<Transaction> recent;
  final Map<String, double> spendingTrend;
  final Map<String, double> categoryBreakdown;
  final List<Budget> topBudgets;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.totalBalance = 0,
    this.monthlyIncome = 0,
    this.monthlyExpense = 0,
    this.savingsRate = 0,
    this.recent = const [],
    this.spendingTrend = const {},
    this.categoryBreakdown = const {},
    this.topBudgets = const [],
    this.errorMessage,
  });

  double get monthlyNet => monthlyIncome - monthlyExpense;

  DashboardState copyWith({
    DashboardStatus? status,
    double? totalBalance,
    double? monthlyIncome,
    double? monthlyExpense,
    double? savingsRate,
    List<Transaction>? recent,
    Map<String, double>? spendingTrend,
    Map<String, double>? categoryBreakdown,
    List<Budget>? topBudgets,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      savingsRate: savingsRate ?? this.savingsRate,
      recent: recent ?? this.recent,
      spendingTrend: spendingTrend ?? this.spendingTrend,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      topBudgets: topBudgets ?? this.topBudgets,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        totalBalance,
        monthlyIncome,
        monthlyExpense,
        savingsRate,
        recent,
        spendingTrend,
        categoryBreakdown,
        topBudgets,
        errorMessage,
      ];
}

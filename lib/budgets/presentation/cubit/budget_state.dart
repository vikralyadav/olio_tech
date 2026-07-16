import 'package:equatable/equatable.dart';

import '../../../core/entities/budget.dart';

enum BudgetStatus { initial, loading, loaded, error }

class BudgetState extends Equatable {
  final BudgetStatus status;
  final List<Budget> budgets;
  final String? errorMessage;

  const BudgetState({
    this.status = BudgetStatus.initial,
    this.budgets = const [],
    this.errorMessage,
  });

  double get totalLimit => budgets.fold(0.0, (s, b) => s + b.limit);
  double get totalSpent => budgets.fold(0.0, (s, b) => s + b.spent);
  double get totalRemaining => totalLimit - totalSpent;
  double get overallProgress =>
      totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.5) : 0.0;
  int get overBudgetCount => budgets.where((b) => b.isOverBudget).length;

  BudgetState copyWith({
    BudgetStatus? status,
    List<Budget>? budgets,
    String? errorMessage,
  }) {
    return BudgetState(
      status: status ?? this.status,
      budgets: budgets ?? this.budgets,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, budgets, errorMessage];
}

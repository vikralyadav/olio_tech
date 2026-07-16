import 'package:equatable/equatable.dart';

class CategoryBreakdown extends Equatable {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;

  const CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [categoryId, categoryName, amount, percentage];
}

class MonthlyReport extends Equatable {
  final String id;
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double savings;
  final double savingsRate;
  final int transactionCount;
  final List<CategoryBreakdown> topCategories;
  final double averageDailySpend;

  const MonthlyReport({
    required this.id,
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.savings,
    required this.savingsRate,
    required this.transactionCount,
    required this.topCategories,
    required this.averageDailySpend,
  });

  double get balance => totalIncome - totalExpense;

  @override
  List<Object?> get props => [
        id,
        year,
        month,
        totalIncome,
        totalExpense,
        savings,
        savingsRate,
        transactionCount,
        topCategories,
        averageDailySpend,
      ];
}

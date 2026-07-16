import '../entities/transaction.dart';

/// Pure, stateless finance computations shared across features.
/// Keeps business logic out of widgets and cubits.
class FinanceCalculator {
  const FinanceCalculator._();

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static double totalIncome(List<Transaction> txns) => txns
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (s, t) => s + t.amount);

  static double totalExpense(List<Transaction> txns) => txns
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  static double balance(List<Transaction> txns) =>
      totalIncome(txns) - totalExpense(txns);

  static List<Transaction> inMonth(List<Transaction> txns, int year, int month) =>
      txns.where((t) => t.date.year == year && t.date.month == month).toList();

  static double monthlyIncome(List<Transaction> txns, DateTime ref) =>
      totalIncome(inMonth(txns, ref.year, ref.month));

  static double monthlyExpense(List<Transaction> txns, DateTime ref) =>
      totalExpense(inMonth(txns, ref.year, ref.month));

  /// Expense total per category name for the given month.
  static Map<String, double> categoryBreakdown(
    List<Transaction> txns,
    int year,
    int month,
  ) {
    final map = <String, double>{};
    for (final t in inMonth(txns, year, month)) {
      if (t.type != TransactionType.expense) continue;
      map[t.categoryName] = (map[t.categoryName] ?? 0) + t.amount;
    }
    return map;
  }

  /// Last [months] months of expense totals keyed by short month label.
  static Map<String, double> monthlyTrend(
    List<Transaction> txns,
    TransactionType type, {
    int months = 6,
    DateTime? reference,
  }) {
    final ref = reference ?? DateTime.now();
    final result = <String, double>{};
    for (int i = months - 1; i >= 0; i--) {
      final d = DateTime(ref.year, ref.month - i, 1);
      final total = txns
          .where((t) =>
              t.type == type &&
              t.date.year == d.year &&
              t.date.month == d.month)
          .fold(0.0, (s, t) => s + t.amount);
      result[_monthNames[d.month - 1]] = total;
    }
    return result;
  }

  static double savingsRate(double income, double expense) =>
      income <= 0 ? 0 : ((income - expense) / income).clamp(-1.0, 1.0);

  static double averageDailySpend(List<Transaction> txns, DateTime ref) {
    final expense = monthlyExpense(txns, ref);
    final daysInMonth = DateTime(ref.year, ref.month + 1, 0).day;
    return daysInMonth == 0 ? 0 : expense / daysInMonth;
  }
}

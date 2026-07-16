import 'package:flutter_test/flutter_test.dart';

import 'package:olio_tech/core/entities/transaction.dart';
import 'package:olio_tech/core/utils/finance_calculator.dart';
import 'package:olio_tech/core/utils/formatters.dart';
import 'package:olio_tech/export/domain/export_service.dart';

void main() {
  final sample = [
    Transaction(
      id: '1',
      title: 'Salary',
      amount: 5000,
      date: DateTime(2026, 7, 1),
      categoryId: 'cat_1',
      categoryName: 'Salary',
      type: TransactionType.income,
    ),
    Transaction(
      id: '2',
      title: 'Groceries',
      amount: 200,
      date: DateTime(2026, 7, 2),
      categoryId: 'cat_13',
      categoryName: 'Groceries',
      type: TransactionType.expense,
    ),
    Transaction(
      id: '3',
      title: 'Dining',
      amount: 300,
      date: DateTime(2026, 7, 3),
      categoryId: 'cat_5',
      categoryName: 'Food & Dining',
      type: TransactionType.expense,
    ),
  ];

  group('FinanceCalculator', () {
    test('computes income, expense and balance', () {
      expect(FinanceCalculator.totalIncome(sample), 5000);
      expect(FinanceCalculator.totalExpense(sample), 500);
      expect(FinanceCalculator.balance(sample), 4500);
    });

    test('computes savings rate', () {
      expect(FinanceCalculator.savingsRate(1000, 750), closeTo(0.25, 0.0001));
      expect(FinanceCalculator.savingsRate(0, 100), 0);
    });

    test('builds a category breakdown for the month', () {
      final breakdown =
          FinanceCalculator.categoryBreakdown(sample, 2026, 7);
      expect(breakdown['Groceries'], 200);
      expect(breakdown['Food & Dining'], 300);
      expect(breakdown.containsKey('Salary'), isFalse);
    });
  });

  group('AppFormatters', () {
    test('formats currency with thousands separators', () {
      expect(AppFormatters.currency(1234.5), r'$1,234.50');
      expect(AppFormatters.currency(-50), r'-$50.00');
    });

    test('formats short currency', () {
      expect(AppFormatters.shortCurrency(1500), r'$1.5K');
    });
  });

  group('ExportService', () {
    const service = ExportService();

    test('CSV includes a header row and one line per transaction', () {
      final csv = service.build(sample, ExportFormat.csv);
      final lines = csv.trim().split('\n');
      expect(lines.first, startsWith('Date,Title,Category'));
      expect(lines.length, sample.length + 1);
    });

    test('summary reports totals', () {
      final summary = service.build(sample, ExportFormat.summary);
      expect(summary, contains('Total transactions : 3'));
      expect(summary, contains('Net balance'));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/transaction.dart';
import '../../../core/utils/finance_calculator.dart';
import '../../../core/utils/formatters.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/repositories/report_repository.dart';
import 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final TransactionRepository transactionRepository;
  final ReportRepository reportRepository;

  AnalyticsCubit({
    required this.transactionRepository,
    required this.reportRepository,
  }) : super(const AnalyticsState());

  Future<void> load() async {
    emit(state.copyWith(status: AnalyticsStatus.loading));
    try {
      final txns = await transactionRepository.getAll();
      final reports = await reportRepository.getMonthlyReports();
      _compute(txns, reports);
    } catch (e) {
      emit(state.copyWith(
          status: AnalyticsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> refresh() => load();

  Future<void> setRange(AnalyticsRange range) async {
    emit(state.copyWith(range: range));
    final txns = await transactionRepository.getAll();
    _compute(txns, state.reports);
  }

  void _compute(List<Transaction> txns, List reports) {
    final months = state.range.months;
    final expenseTrend = FinanceCalculator.monthlyTrend(
        txns, TransactionType.expense,
        months: months);
    final incomeTrend =
        FinanceCalculator.monthlyTrend(txns, TransactionType.income, months: months);

    final now = DateTime.now();
    final breakdown =
        FinanceCalculator.categoryBreakdown(txns, now.year, now.month);

    final avgExpense = expenseTrend.values.isEmpty
        ? 0.0
        : expenseTrend.values.reduce((a, b) => a + b) / expenseTrend.length;
    final avgIncome = incomeTrend.values.isEmpty
        ? 0.0
        : incomeTrend.values.reduce((a, b) => a + b) / incomeTrend.length;

    emit(state.copyWith(
      status: AnalyticsStatus.loaded,
      expenseTrend: expenseTrend,
      incomeTrend: incomeTrend,
      categoryBreakdown: breakdown,
      reports: reports.cast(),
      avgMonthlyExpense: avgExpense,
      avgMonthlyIncome: avgIncome,
      insights: _insights(
          expenseTrend, incomeTrend, breakdown, avgExpense, avgIncome),
    ));
  }

  List<Insight> _insights(
    Map<String, double> expenseTrend,
    Map<String, double> incomeTrend,
    Map<String, double> breakdown,
    double avgExpense,
    double avgIncome,
  ) {
    final insights = <Insight>[];

    // Month-over-month expense change.
    final exp = expenseTrend.values.toList();
    if (exp.length >= 2 && exp[exp.length - 2] > 0) {
      final change = (exp.last - exp[exp.length - 2]) / exp[exp.length - 2];
      final up = change >= 0;
      insights.add(Insight(
        icon: up ? Icons.trending_up : Icons.trending_down,
        color: up ? Colors.red : Colors.green,
        title: up ? 'Spending increased' : 'Spending decreased',
        detail:
            'Your spending ${up ? 'rose' : 'fell'} ${AppFormatters.percentage(change.abs())} vs last month.',
      ));
    }

    // Savings health.
    final savingsRate =
        FinanceCalculator.savingsRate(avgIncome, avgExpense);
    insights.add(Insight(
      icon: Icons.savings,
      color: savingsRate >= 0.2 ? Colors.green : Colors.orange,
      title: 'Savings rate ${AppFormatters.percentage(savingsRate)}',
      detail: savingsRate >= 0.2
          ? 'Great! You are saving a healthy share of your income.'
          : 'Consider trimming expenses to boost your savings.',
    ));

    // Top category.
    if (breakdown.isNotEmpty) {
      final top = breakdown.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add(Insight(
        icon: Icons.pie_chart,
        color: Colors.purple,
        title: 'Top category: ${top.key}',
        detail:
            'You spent ${AppFormatters.currency(top.value)} on ${top.key} this month.',
      ));
    }

    // Average daily spend.
    insights.add(Insight(
      icon: Icons.today,
      color: Colors.blue,
      title: 'Avg. monthly spend',
      detail:
          'You spend about ${AppFormatters.currency(avgExpense)} per month on average.',
    ));

    return insights;
  }
}

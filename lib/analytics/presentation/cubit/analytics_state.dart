import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../core/entities/monthly_report.dart';

class Insight extends Equatable {
  final IconData icon;
  final Color color;
  final String title;
  final String detail;

  const Insight({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });

  @override
  List<Object?> get props => [icon, color, title, detail];
}

enum AnalyticsStatus { initial, loading, loaded, error }

enum AnalyticsRange { threeMonths, sixMonths, twelveMonths }

extension AnalyticsRangeX on AnalyticsRange {
  int get months {
    switch (this) {
      case AnalyticsRange.threeMonths:
        return 3;
      case AnalyticsRange.sixMonths:
        return 6;
      case AnalyticsRange.twelveMonths:
        return 12;
    }
  }

  String get label {
    switch (this) {
      case AnalyticsRange.threeMonths:
        return '3M';
      case AnalyticsRange.sixMonths:
        return '6M';
      case AnalyticsRange.twelveMonths:
        return '12M';
    }
  }
}

class AnalyticsState extends Equatable {
  final AnalyticsStatus status;
  final AnalyticsRange range;
  final Map<String, double> expenseTrend;
  final Map<String, double> incomeTrend;
  final Map<String, double> categoryBreakdown;
  final List<MonthlyReport> reports;
  final List<Insight> insights;
  final double avgMonthlyExpense;
  final double avgMonthlyIncome;
  final String? errorMessage;

  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.range = AnalyticsRange.sixMonths,
    this.expenseTrend = const {},
    this.incomeTrend = const {},
    this.categoryBreakdown = const {},
    this.reports = const [],
    this.insights = const [],
    this.avgMonthlyExpense = 0,
    this.avgMonthlyIncome = 0,
    this.errorMessage,
  });

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    AnalyticsRange? range,
    Map<String, double>? expenseTrend,
    Map<String, double>? incomeTrend,
    Map<String, double>? categoryBreakdown,
    List<MonthlyReport>? reports,
    List<Insight>? insights,
    double? avgMonthlyExpense,
    double? avgMonthlyIncome,
    String? errorMessage,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      range: range ?? this.range,
      expenseTrend: expenseTrend ?? this.expenseTrend,
      incomeTrend: incomeTrend ?? this.incomeTrend,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      reports: reports ?? this.reports,
      insights: insights ?? this.insights,
      avgMonthlyExpense: avgMonthlyExpense ?? this.avgMonthlyExpense,
      avgMonthlyIncome: avgMonthlyIncome ?? this.avgMonthlyIncome,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        range,
        expenseTrend,
        incomeTrend,
        categoryBreakdown,
        reports,
        insights,
        avgMonthlyExpense,
        avgMonthlyIncome,
        errorMessage,
      ];
}

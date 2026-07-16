import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/monthly_report.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/charts/category_donut_chart.dart';
import '../../../core/widgets/charts/grouped_bar_chart.dart';
import '../../../core/widgets/charts/trend_line_chart.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/state_views.dart';
import '../cubit/analytics_cubit.dart';
import '../cubit/analytics_state.dart';

class AnalyticsPage extends StatefulWidget {
  final bool showAppBar;
  const AnalyticsPage({super.key, this.showAppBar = true});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<AnalyticsCubit>();
    if (cubit.state.status == AnalyticsStatus.initial) cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AnalyticsCubit>();
    return Scaffold(
      appBar:
          widget.showAppBar ? AppBar(title: const Text('Analytics')) : null,
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          if (state.status == AnalyticsStatus.loading &&
              state.expenseTrend.isEmpty) {
            return const LoadingView(message: 'Crunching your numbers...');
          }
          if (state.status == AnalyticsStatus.error) {
            return ErrorView(
                message: state.errorMessage ?? 'Failed', onRetry: cubit.load);
          }
          return RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _RangeSelector(state: state),
                const SizedBox(height: 8),
                _AveragesRow(state: state),
                const SizedBox(height: 8),
                const SectionHeader(title: 'Income vs Expense'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                    child: Column(
                      children: [
                        GroupedBarChart(
                          points: _incomeVsExpense(state),
                          primaryColor: AppTheme.incomeColor,
                          secondaryColor: AppTheme.expenseColor,
                        ),
                        const SizedBox(height: 8),
                        _legend(context),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const SectionHeader(title: 'Spending Trend'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                    child: TrendLineChart(
                      data: state.expenseTrend,
                      color: AppTheme.expenseColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (state.categoryBreakdown.isNotEmpty) ...[
                  const SectionHeader(title: 'Category Breakdown'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CategoryDonutChart(slices: _slices(state)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                const SectionHeader(title: 'Insights'),
                ...state.insights.map((i) => _InsightTile(insight: i)),
                const SizedBox(height: 8),
                const SectionHeader(title: 'Monthly Reports'),
                ...state.reports.map((r) => _ReportTile(report: r)),
              ],
            ),
          );
        },
      ),
    );
  }

  List<BarSeriesPoint> _incomeVsExpense(AnalyticsState state) {
    final keys = state.expenseTrend.keys.toList();
    return [
      for (final k in keys)
        BarSeriesPoint(
          k,
          state.incomeTrend[k] ?? 0,
          secondary: state.expenseTrend[k] ?? 0,
        ),
    ];
  }

  List<DonutSlice> _slices(AnalyticsState state) {
    final entries = state.categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(6).toList();
    return [
      for (int i = 0; i < top.length; i++)
        DonutSlice(top[i].key, top[i].value, AppFormatters.getCategoryColor(i)),
    ];
  }

  Widget _legend(BuildContext context) {
    Widget dot(Color c, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: c, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        dot(AppTheme.incomeColor, 'Income'),
        const SizedBox(width: 20),
        dot(AppTheme.expenseColor, 'Expense'),
      ],
    );
  }
}

class _RangeSelector extends StatelessWidget {
  final AnalyticsState state;
  const _RangeSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AnalyticsCubit>();
    return SegmentedButton<AnalyticsRange>(
      segments: AnalyticsRange.values
          .map((r) => ButtonSegment(value: r, label: Text(r.label)))
          .toList(),
      selected: {state.range},
      onSelectionChanged: (s) => cubit.setRange(s.first),
    );
  }
}

class _AveragesRow extends StatelessWidget {
  final AnalyticsState state;
  const _AveragesRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _tile(context, 'Avg Income',
              AppFormatters.currency(state.avgMonthlyIncome),
              AppTheme.incomeColor, Icons.arrow_downward),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _tile(context, 'Avg Expense',
              AppFormatters.currency(state.avgMonthlyExpense),
              AppTheme.expenseColor, Icons.arrow_upward),
        ),
      ],
    );
  }

  Widget _tile(BuildContext context, String label, String value, Color color,
      IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: color)),
                  Text(label,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final Insight insight;
  const _InsightTile({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: insight.color.withValues(alpha: 0.15),
          child: Icon(insight.icon, color: insight.color),
        ),
        title: Text(insight.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(insight.detail),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final MonthlyReport report;
  const _ReportTile({required this.report});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final positive = report.savings >= 0;
    return Card(
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Text('${report.month}',
              style: TextStyle(color: scheme.onPrimaryContainer)),
        ),
        title: Text(AppFormatters.monthYear(report.month, report.year),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            'Saved ${AppFormatters.currency(report.savings)} • ${AppFormatters.percentage(report.savingsRate)}'),
        trailing: Icon(
          positive ? Icons.trending_up : Icons.trending_down,
          color: positive ? AppTheme.incomeColor : AppTheme.expenseColor,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _row(context, 'Income', AppFormatters.currency(report.totalIncome),
              AppTheme.incomeColor),
          _row(context, 'Expense', AppFormatters.currency(report.totalExpense),
              AppTheme.expenseColor),
          _row(context, 'Transactions', '${report.transactionCount}', null),
          _row(context, 'Avg daily spend',
              AppFormatters.currency(report.averageDailySpend), null),
          const Divider(),
          ...report.topCategories.map(
            (c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(child: Text(c.categoryName)),
                  Text(AppFormatters.currency(c.amount),
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

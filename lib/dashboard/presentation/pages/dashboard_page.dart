import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/transaction.dart';
import '../../../core/routes/routes_name.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/category_avatar.dart';
import '../../../core/widgets/charts/category_donut_chart.dart';
import '../../../core/widgets/charts/trend_line_chart.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../../../notifications/presentation/cubit/notification_cubit.dart';
import '../../../notifications/presentation/cubit/notification_state.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../transactions/presentation/cubit/transaction_cubit.dart';
import '../../../transactions/presentation/pages/transaction_detail_page.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

class DashboardPage extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;
  const DashboardPage({super.key, this.onNavigateTab});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<DashboardCubit>();
    if (cubit.state.status == DashboardStatus.initial) cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state.status == DashboardStatus.loading &&
                state.recent.isEmpty) {
              return const LoadingView(message: 'Loading your dashboard...');
            }
            if (state.status == DashboardStatus.error) {
              return ErrorView(
                  message: state.errorMessage ?? 'Failed', onRetry: cubit.load);
            }
            return RefreshIndicator(
              onRefresh: cubit.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  const _Header(),
                  const SizedBox(height: 16),
                  _BalanceCard(state: state),
                  const SizedBox(height: 16),
                  _QuickStats(state: state),
                  const SizedBox(height: 8),
                  const SectionHeader(title: 'Quick Actions'),
                  const _QuickActions(),
                  const SizedBox(height: 8),
                  SectionHeader(
                    title: 'Spending Trend',
                    actionLabel: 'Analytics',
                    onAction: () => widget.onNavigateTab?.call(3),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                      child: state.spendingTrend.isEmpty
                          ? const SizedBox(
                              height: 180,
                              child: Center(child: Text('No data')))
                          : TrendLineChart(
                              data: state.spendingTrend,
                              color: AppTheme.expenseColor,
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (state.categoryBreakdown.isNotEmpty) ...[
                    const SectionHeader(title: 'Top Categories'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CategoryDonutChart(
                          slices: _topSlices(state.categoryBreakdown),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (state.topBudgets.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Budgets',
                      actionLabel: 'See all',
                      onAction: () => widget.onNavigateTab?.call(2),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            for (final b in state.topBudgets)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(b.categoryName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: AppProgressBar(
                                        value: b.percentage,
                                        color: b.isOverBudget
                                            ? Theme.of(context).colorScheme.error
                                            : CategoryVisuals.colorFor(
                                                b.categoryId),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppFormatters.percentage(b.percentage),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SectionHeader(
                    title: 'Recent Transactions',
                    actionLabel: 'See all',
                    onAction: () => widget.onNavigateTab?.call(1),
                  ),
                  if (state.recent.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No transactions yet')),
                    )
                  else
                    ...state.recent.map(
                      (t) => TransactionTile(
                        transaction: t,
                        onTap: () => _openTransaction(t),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openTransaction(Transaction t) {
    final txnCubit = context.read<TransactionCubit>();
    final dashboardCubit = context.read<DashboardCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TransactionDetailPage(cubit: txnCubit, transaction: t),
      ),
    ).then((_) => dashboardCubit.refresh());
  }

  List<DonutSlice> _topSlices(Map<String, double> breakdown) {
    final entries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(5).toList();
    return [
      for (int i = 0; i < top.length; i++)
        DonutSlice(top[i].key, top[i].value, AppFormatters.getCategoryColor(i)),
    ];
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.document_scanner_outlined, 'Scan', RouteNames.receipts),
      (Icons.subscriptions_outlined, 'Subs', RouteNames.subscriptions),
      (Icons.file_download_outlined, 'Export', RouteNames.export),
      (Icons.notifications_outlined, 'Alerts', RouteNames.notifications),
    ];
    return Row(
      children: [
        for (final a in actions)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _ActionButton(
                icon: a.$1,
                label: a.$2,
                onTap: () => Navigator.pushNamed(context, a.$3),
              ),
            ),
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(height: 6),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back 👋',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text('Your Finances',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            return IconButton.filledTonal(
              onPressed: () {
                final notifCubit = context.read<NotificationCubit>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: notifCubit,
                      child: const NotificationsPage(),
                    ),
                  ),
                );
              },
              icon: Badge(
                isLabelVisible: state.unreadCount > 0,
                label: Text('${state.unreadCount}'),
                child: const Icon(Icons.notifications_outlined),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final DashboardState state;
  const _BalanceCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Balance',
              style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.8))),
          const SizedBox(height: 8),
          Text(
            AppFormatters.currency(state.totalBalance),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _miniStat(context, Icons.arrow_downward, 'Income',
                  AppFormatters.currency(state.monthlyIncome)),
              const SizedBox(width: 24),
              _miniStat(context, Icons.arrow_upward, 'Expense',
                  AppFormatters.currency(state.monthlyExpense)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(
      BuildContext context, IconData icon, String label, String value) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: onPrimary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: onPrimary),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: onPrimary.withValues(alpha: 0.8))),
            Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: onPrimary)),
          ],
        ),
      ],
    );
  }
}

class _QuickStats extends StatelessWidget {
  final DashboardState state;
  const _QuickStats({required this.state});

  @override
  Widget build(BuildContext context) {
    final net = state.monthlyNet;
    return Row(
      children: [
        Expanded(
          child: _card(
            context,
            Icons.savings_outlined,
            'Net This Month',
            AppFormatters.currency(net),
            net >= 0 ? AppTheme.incomeColor : AppTheme.expenseColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _card(
            context,
            Icons.percent,
            'Savings Rate',
            AppFormatters.percentage(state.savingsRate),
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, IconData icon, String label, String value,
      Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

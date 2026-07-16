import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/budget.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/state_views.dart';
import '../cubit/budget_cubit.dart';
import '../cubit/budget_state.dart';
import '../widgets/budget_card.dart';
import 'budget_form_page.dart';

class BudgetsPage extends StatefulWidget {
  final bool showAppBar;
  const BudgetsPage({super.key, this.showAppBar = true});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<BudgetCubit>();
    if (cubit.state.status == BudgetStatus.initial) cubit.load();
  }

  void _openForm({Budget? initial}) {
    final cubit = context.read<BudgetCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BudgetFormPage(cubit: cubit, initial: initial),
      ),
    );
  }

  Future<void> _confirmDelete(Budget b) async {
    final cubit = context.read<BudgetCubit>();
    final ok = await showConfirmDialog(
      context,
      title: 'Delete Budget',
      message: 'Delete the ${b.categoryName} budget?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (ok) cubit.remove(b.id);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BudgetCubit>();
    return Scaffold(
      appBar:
          widget.showAppBar ? AppBar(title: const Text('Budgets')) : null,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_budgets',
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('New Budget'),
      ),
      body: BlocBuilder<BudgetCubit, BudgetState>(
        builder: (context, state) {
          if (state.status == BudgetStatus.loading && state.budgets.isEmpty) {
            return const LoadingView(message: 'Loading budgets...');
          }
          if (state.status == BudgetStatus.error) {
            return ErrorView(
                message: state.errorMessage ?? 'Failed', onRetry: cubit.load);
          }
          if (state.budgets.isEmpty) {
            return EmptyView(
              icon: Icons.savings_outlined,
              title: 'No budgets yet',
              message: 'Create a budget to track your spending limits.',
              actionLabel: 'New Budget',
              onAction: () => _openForm(),
            );
          }
          return RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                _OverviewCard(state: state),
                const SizedBox(height: 16),
                ...state.budgets.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BudgetCard(
                      budget: b,
                      onTap: () => _showActions(b),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showActions(Budget b) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit budget'),
              onTap: () {
                Navigator.pop(context);
                _openForm(initial: b);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              title: const Text('Delete budget'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(b);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final BudgetState state;
  const _OverviewCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final over = state.overBudgetCount > 0;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This Month',
                style: TextStyle(color: scheme.onPrimaryContainer)),
            const SizedBox(height: 6),
            Text(
              '${AppFormatters.currency(state.totalSpent)} / ${AppFormatters.currency(state.totalLimit)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            AppProgressBar(
              value: state.overallProgress,
              color: over ? scheme.error : scheme.primary,
              height: 10,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  over ? Icons.error_outline : Icons.check_circle_outline,
                  size: 18,
                  color: scheme.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  over
                      ? '${state.overBudgetCount} over budget • ${AppFormatters.currency(state.totalRemaining)} left'
                      : '${AppFormatters.currency(state.totalRemaining)} remaining',
                  style: TextStyle(color: scheme.onPrimaryContainer),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

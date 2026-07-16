import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/transaction.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/category_avatar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../cubit/transaction_cubit.dart';
import '../cubit/transaction_state.dart';
import '../widgets/transaction_filter_sheet.dart';
import 'transaction_detail_page.dart';
import 'transaction_form_page.dart';

class TransactionsPage extends StatefulWidget {
  final bool showAppBar;
  const TransactionsPage({super.key, this.showAppBar = true});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _debouncer = Debouncer();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<TransactionCubit>();
    if (cubit.state.status == TransactionStatus.initial) {
      cubit.load();
    }
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<TransactionCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openForm({Transaction? initial}) {
    final cubit = context.read<TransactionCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormPage(cubit: cubit, initial: initial),
      ),
    );
  }

  void _openDetail(Transaction t) {
    final cubit = context.read<TransactionCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailPage(cubit: cubit, transaction: t),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransactionCubit>();
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Transactions'))
          : null,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_transactions',
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            onChanged: (v) => _debouncer.run(() => cubit.search(v)),
            onFilter: () => TransactionFilterSheet.show(context),
          ),
          const _ActiveFiltersBar(),
          const _SummaryBar(),
          Expanded(
            child: BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, state) {
                if (state.status == TransactionStatus.loading &&
                    state.all.isEmpty) {
                  return const LoadingView(message: 'Loading transactions...');
                }
                if (state.status == TransactionStatus.error) {
                  return ErrorView(
                    message: state.errorMessage ?? 'Failed to load',
                    onRetry: cubit.load,
                  );
                }
                final items = state.visible;
                if (items.isEmpty) {
                  return EmptyView(
                    icon: Icons.receipt_long_outlined,
                    title: state.hasActiveFilters
                        ? 'No matching transactions'
                        : 'No transactions yet',
                    message: state.hasActiveFilters
                        ? 'Try adjusting your search or filters.'
                        : 'Add your first transaction to get started.',
                    actionLabel: state.hasActiveFilters ? null : 'Add Transaction',
                    onAction: state.hasActiveFilters ? null : () => _openForm(),
                  );
                }
                return RefreshIndicator(
                  onRefresh: cubit.refresh,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: items.length + (state.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index >= items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final t = items[index];
                      return Dismissible(
                        key: ValueKey(t.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          color: AppTheme.expenseColor,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) => showConfirmDialog(
                          context,
                          title: 'Delete Transaction',
                          message: 'Delete "${t.title}"?',
                          confirmLabel: 'Delete',
                          destructive: true,
                        ),
                        onDismissed: (_) {
                          cubit.remove(t.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Transaction deleted')),
                          );
                        },
                        child: TransactionTile(
                          transaction: t,
                          onTap: () => _openDetail(t),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                      )
                    : null,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: onFilter,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
    );
  }
}

class _ActiveFiltersBar extends StatelessWidget {
  const _ActiveFiltersBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      buildWhen: (a, b) =>
          a.typeFilter != b.typeFilter ||
          a.categoryFilter != b.categoryFilter,
      builder: (context, state) {
        final cubit = context.read<TransactionCubit>();
        final chips = <Widget>[];
        if (state.typeFilter != null) {
          chips.add(InputChip(
            label: Text(state.typeFilter == TransactionType.income
                ? 'Income'
                : 'Expense'),
            onDeleted: () => cubit.filterByType(null),
          ));
        }
        if (state.categoryFilter != null) {
          final name = CategoryVisuals.byId(state.categoryFilter)?.name ??
              'Category';
          chips.add(InputChip(
            label: Text(name),
            onDeleted: () => cubit.filterByCategory(null),
          ));
        }
        if (chips.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final c in chips) ...[c, const SizedBox(width: 8)],
              ActionChip(
                label: const Text('Clear all'),
                onPressed: cubit.clearFilters,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state.all.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: _pill(context, 'Income',
                    AppFormatters.currency(state.filteredIncome),
                    AppTheme.incomeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _pill(context, 'Expense',
                    AppFormatters.currency(state.filteredExpense),
                    AppTheme.expenseColor),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pill(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: color)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

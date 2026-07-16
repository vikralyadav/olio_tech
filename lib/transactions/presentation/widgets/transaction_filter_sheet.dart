import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/entities/transaction.dart';
import '../cubit/transaction_cubit.dart';
import '../cubit/transaction_state.dart';

/// Bottom sheet to filter and sort the transaction list.
class TransactionFilterSheet extends StatelessWidget {
  const TransactionFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<TransactionCubit>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const TransactionFilterSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransactionCubit>();
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              Row(
                children: [
                  Text('Filter & Sort',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      cubit.clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Type', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: state.typeFilter == null,
                    onSelected: (_) => cubit.filterByType(null),
                  ),
                  ChoiceChip(
                    label: const Text('Income'),
                    selected: state.typeFilter == TransactionType.income,
                    onSelected: (_) => cubit.filterByType(TransactionType.income),
                  ),
                  ChoiceChip(
                    label: const Text('Expense'),
                    selected: state.typeFilter == TransactionType.expense,
                    onSelected: (_) =>
                        cubit.filterByType(TransactionType.expense),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Category', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: state.categoryFilter == null,
                    onSelected: (_) => cubit.filterByCategory(null),
                  ),
                  ...MockData.categories.map(
                    (c) => ChoiceChip(
                      avatar: Icon(c.icon, size: 16, color: c.color),
                      label: Text(c.name),
                      selected: state.categoryFilter == c.id,
                      onSelected: (_) => cubit.filterByCategory(c.id),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Sort by', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...TransactionSort.values.map(
                (s) => RadioListTile<TransactionSort>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.label),
                  value: s,
                  groupValue: state.sort,
                  onChanged: (v) => cubit.setSort(v!),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply'),
              ),
            ],
          ),
        );
      },
    );
  }
}

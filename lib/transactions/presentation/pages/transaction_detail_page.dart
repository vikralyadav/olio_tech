import 'package:flutter/material.dart';

import '../../../core/entities/transaction.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/category_avatar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../cubit/transaction_cubit.dart';
import 'transaction_form_page.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionCubit cubit;
  final Transaction transaction;

  const TransactionDetailPage({
    super.key,
    required this.cubit,
    required this.transaction,
  });

  Future<void> _edit(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormPage(cubit: cubit, initial: transaction),
      ),
    );
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Transaction',
      message: 'Are you sure you want to delete "${transaction.title}"?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed) {
      await cubit.remove(transaction.id);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final isExpense = t.type == TransactionType.expense;
    final color = isExpense ? AppTheme.expenseColor : AppTheme.incomeColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _edit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CategoryAvatar(categoryId: t.categoryId, size: 72),
                const SizedBox(height: 16),
                Text(
                  '${isExpense ? '-' : '+'} ${AppFormatters.currency(t.amount)}',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: color, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(t.title,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: [
                _row(context, Icons.category, 'Category', t.categoryName),
                const Divider(height: 1),
                _row(context, Icons.calendar_today, 'Date',
                    AppFormatters.date(t.date)),
                const Divider(height: 1),
                _row(
                  context,
                  isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                  'Type',
                  isExpense ? 'Expense' : 'Income',
                ),
                const Divider(height: 1),
                _row(context, Icons.autorenew, 'Recurring',
                    t.isRecurring ? 'Yes' : 'No'),
                if (t.note != null) ...[
                  const Divider(height: 1),
                  _row(context, Icons.note_alt_outlined, 'Note', t.note!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () => _edit(context),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Transaction'),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}

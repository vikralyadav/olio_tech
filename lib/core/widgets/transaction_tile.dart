import 'package:flutter/material.dart';

import '../entities/transaction.dart';
import '../utils/formatters.dart';
import 'amount_text.dart';
import 'category_avatar.dart';

/// Reusable list tile representing a single transaction.
class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final bool showDate;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: CategoryAvatar(categoryId: t.categoryId),
      title: Text(
        t.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              t.categoryName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showDate) ...[
            const Text('  •  '),
            Text(AppFormatters.relativeDate(t.date)),
          ],
          if (t.isRecurring) ...[
            const SizedBox(width: 6),
            Icon(Icons.autorenew,
                size: 14, color: Theme.of(context).colorScheme.primary),
          ],
        ],
      ),
      trailing: AmountText(
        amount: t.amount,
        isExpense: t.type == TransactionType.expense,
      ),
    );
  }
}

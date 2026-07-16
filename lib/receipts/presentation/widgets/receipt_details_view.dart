import 'package:flutter/material.dart';

import '../../../core/entities/receipt.dart';
import '../../../core/utils/formatters.dart';

/// Shared visual layout for a parsed/scanned receipt (items + totals).
class ReceiptDetailsView extends StatelessWidget {
  final Receipt receipt;
  const ReceiptDetailsView({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subtotal = receipt.totalAmount - (receipt.taxAmount ?? 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: scheme.primaryContainer,
              child: Icon(Icons.store, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(receipt.merchantName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold)),
                  Text(AppFormatters.date(receipt.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            Text(
              AppFormatters.currency(receipt.totalAmount),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('Items (${receipt.items.length})',
              style: Theme.of(context).textTheme.titleSmall),
        ),
        ...receipt.items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${item.quantity}×',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name),
                      Text('${AppFormatters.currency(item.unitPrice)} each',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Text(AppFormatters.currency(item.totalPrice),
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        const Divider(),
        _totalRow(context, 'Subtotal', subtotal),
        if (receipt.taxAmount != null)
          _totalRow(context, 'Tax', receipt.taxAmount!),
        _totalRow(context, 'Total', receipt.totalAmount, bold: true),
      ],
    );
  }

  Widget _totalRow(BuildContext context, String label, double value,
      {bool bold = false}) {
    final style = bold
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(AppFormatters.currency(value), style: style),
        ],
      ),
    );
  }
}

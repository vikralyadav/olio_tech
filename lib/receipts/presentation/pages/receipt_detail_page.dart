import 'package:flutter/material.dart';

import '../../../core/entities/receipt.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../cubit/receipt_cubit.dart';
import '../widgets/receipt_details_view.dart';

class ReceiptDetailPage extends StatelessWidget {
  final ReceiptCubit cubit;
  final Receipt receipt;

  const ReceiptDetailPage({
    super.key,
    required this.cubit,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showConfirmDialog(
                context,
                title: 'Delete Receipt',
                message: 'Delete this receipt from ${receipt.merchantName}?',
                confirmLabel: 'Delete',
                destructive: true,
              );
              if (ok) {
                await cubit.remove(receipt.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ReceiptDetailsView(receipt: receipt),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () async {
              await cubit.convertToTransaction(receipt);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Transaction created from receipt')),
                );
              }
            },
            icon: const Icon(Icons.add_card),
            label: const Text('Add as Transaction'),
          ),
        ],
      ),
    );
  }
}

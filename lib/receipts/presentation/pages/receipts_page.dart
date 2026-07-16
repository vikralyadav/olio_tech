import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/receipt.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../cubit/receipt_cubit.dart';
import '../cubit/receipt_state.dart';
import 'receipt_detail_page.dart';
import 'scan_receipt_page.dart';

class ReceiptsPage extends StatefulWidget {
  final bool showAppBar;
  const ReceiptsPage({super.key, this.showAppBar = true});

  @override
  State<ReceiptsPage> createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ReceiptCubit>();
    if (cubit.state.status == ReceiptStatus.initial) cubit.load();
  }

  void _openScan() {
    final cubit = context.read<ReceiptCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const ScanReceiptPage(),
        ),
      ),
    );
  }

  void _openDetail(Receipt r) {
    final cubit = context.read<ReceiptCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptDetailPage(cubit: cubit, receipt: r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReceiptCubit>();
    return Scaffold(
      appBar:
          widget.showAppBar ? AppBar(title: const Text('Receipts')) : null,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_receipts',
        onPressed: _openScan,
        icon: const Icon(Icons.document_scanner),
        label: const Text('Scan'),
      ),
      body: BlocBuilder<ReceiptCubit, ReceiptState>(
        builder: (context, state) {
          if (state.status == ReceiptStatus.loading &&
              state.receipts.isEmpty) {
            return const LoadingView(message: 'Loading receipts...');
          }
          if (state.status == ReceiptStatus.error) {
            return ErrorView(
                message: state.errorMessage ?? 'Failed', onRetry: cubit.load);
          }
          if (state.receipts.isEmpty) {
            return EmptyView(
              icon: Icons.receipt_outlined,
              title: 'No receipts yet',
              message: 'Scan a receipt to extract items automatically.',
              actionLabel: 'Scan Receipt',
              onAction: _openScan,
            );
          }
          return RefreshIndicator(
            onRefresh: cubit.refresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _SummaryHeader(state: state)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ReceiptGridCard(
                        receipt: state.receipts[index],
                        onTap: () => _openDetail(state.receipts[index]),
                      ),
                      childCount: state.receipts.length,
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
}

class _SummaryHeader extends StatelessWidget {
  final ReceiptState state;
  const _SummaryHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _tile(context, Icons.receipt_long, 'Receipts',
                '${state.receipts.length}', scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _tile(context, Icons.payments_outlined, 'Total',
                AppFormatters.currency(state.totalScanned), scheme.tertiary),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, String value,
      Color color) {
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
                          fontWeight: FontWeight.bold)),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptGridCard extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onTap;
  const _ReceiptGridCard({required this.receipt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              width: double.infinity,
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              child: Icon(Icons.receipt_long,
                  size: 40, color: scheme.onPrimaryContainer),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(receipt.merchantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('${receipt.items.length} items',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text(AppFormatters.currency(receipt.totalAmount),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold, color: scheme.primary)),
                  Text(AppFormatters.shortDate(receipt.date),
                      style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

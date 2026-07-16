import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/receipt_cubit.dart';
import '../cubit/receipt_state.dart';
import '../widgets/receipt_details_view.dart';

/// Simulated receipt scanning flow: an animated scanner, then a parsed
/// preview the user can confirm to save (which also creates a transaction).
class ScanReceiptPage extends StatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReceiptCubit>().scan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReceiptCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Receipt')),
      body: BlocBuilder<ReceiptCubit, ReceiptState>(
        builder: (context, state) {
          if (state.scanStatus == ScanStatus.scanning) {
            return const _ScanningView();
          }
          if (state.scanStatus == ScanStatus.scanned && state.scanned != null) {
            return _ResultView(
              onSave: () async {
                await cubit.saveScanned(state.scanned!);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Receipt saved & transaction created')),
                  );
                }
              },
              onRetry: cubit.scan,
            );
          }
          return Center(
            child: FilledButton.icon(
              onPressed: cubit.scan,
              icon: const Icon(Icons.document_scanner),
              label: const Text('Start Scan'),
            ),
          );
        },
      ),
    );
  }
}

class _ScanningView extends StatefulWidget {
  const _ScanningView();

  @override
  State<_ScanningView> createState() => _ScanningViewState();
}

class _ScanningViewState extends State<_ScanningView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 260,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Icon(Icons.receipt_long,
                      size: 120, color: scheme.onSurfaceVariant),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => Positioned(
                    top: _controller.value * 240,
                    left: 8,
                    right: 8,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        boxShadow: [
                          BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.6),
                              blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Scanning & extracting data...',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Reading merchant, items and totals',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onRetry;
  const _ResultView({required this.onSave, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReceiptCubit>().state;
    final receipt = state.scanned!;
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.green.withValues(alpha: 0.12),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Receipt scanned successfully'),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ReceiptDetailsView(receipt: receipt),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Rescan'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.check),
                    label: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

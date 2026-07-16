import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/entities/transaction.dart';
import '../../../core/widgets/state_views.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/export_service.dart';

class ExportPage extends StatefulWidget {
  final TransactionRepository repository;
  const ExportPage({super.key, required this.repository});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  static const _service = ExportService();
  ExportFormat _format = ExportFormat.csv;
  List<Transaction>? _transactions;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final txns = await widget.repository.getAll();
    if (!mounted) return;
    setState(() {
      _transactions = txns;
      _loading = false;
    });
  }

  String get _content =>
      _transactions == null ? '' : _service.build(_transactions!, _format);

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _content));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _export() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 40),
        title: const Text('Export Ready'),
        content: Text(
          'Exported ${_transactions?.length ?? 0} transactions as '
          'transactions.${_format.extension}.\n\n'
          'In a production build this would be saved to your device or shared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _copy();
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _copy,
            icon: const Icon(Icons.copy),
            tooltip: 'Copy',
          ),
        ],
      ),
      body: _loading
          ? const LoadingView(message: 'Preparing your data...')
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SegmentedButton<ExportFormat>(
                    segments: ExportFormat.values
                        .map((f) =>
                            ButtonSegment(value: f, label: Text(f.label)))
                        .toList(),
                    selected: {_format},
                    onSelectionChanged: (s) =>
                        setState(() => _format = s.first),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.description_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        '${_transactions?.length ?? 0} transactions • '
                        'transactions.${_format.extension}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _content,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _loading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _export,
                  icon: const Icon(Icons.download),
                  label: Text('Export as ${_format.label}'),
                ),
              ),
            ),
    );
  }
}

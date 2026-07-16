import 'package:flutter/material.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/entities/category.dart';
import '../../../core/entities/transaction.dart';
import '../cubit/transaction_cubit.dart';

/// Add or edit a transaction. Pass [initial] to edit.
class TransactionFormPage extends StatefulWidget {
  final TransactionCubit cubit;
  final Transaction? initial;

  const TransactionFormPage({super.key, required this.cubit, this.initial});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _type;
  Category? _category;
  late DateTime _date;
  bool _isRecurring = false;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    _titleController = TextEditingController(text: t?.title ?? '');
    _amountController =
        TextEditingController(text: t != null ? t.amount.toString() : '');
    _noteController = TextEditingController(text: t?.note ?? '');
    _type = t?.type ?? TransactionType.expense;
    _date = t?.date ?? DateTime.now();
    _isRecurring = t?.isRecurring ?? false;
    _category = t != null
        ? MockData.categories.firstWhere(
            (c) => c.id == t.categoryId,
            orElse: () => _categoriesForType(_type).first,
          )
        : _categoriesForType(_type).first;
  }

  List<Category> _categoriesForType(TransactionType type) {
    final catType =
        type == TransactionType.income ? CategoryType.income : CategoryType.expense;
    return MockData.categories.where((c) => c.type == catType).toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _type = type;
      _category = _categoriesForType(type).first;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _category == null) return;
    setState(() => _saving = true);

    final amount = double.parse(_amountController.text.trim());
    final base = widget.initial;
    final transaction = Transaction(
      id: base?.id ?? 'txn_${DateTime.now().microsecondsSinceEpoch}',
      title: _titleController.text.trim(),
      amount: amount,
      date: _date,
      categoryId: _category!.id,
      categoryName: _category!.name,
      type: _type,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      receiptId: base?.receiptId,
      isRecurring: _isRecurring,
    );

    if (_isEditing) {
      await widget.cubit.edit(transaction);
    } else {
      await widget.cubit.create(transaction);
    }

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Transaction updated' : 'Transaction added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoriesForType(_type);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => _onTypeChanged(s.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Amount is required';
                final parsed = double.tryParse(v.trim());
                if (parsed == null) return 'Enter a valid number';
                if (parsed <= 0) return 'Amount must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Category>(
              initialValue: categories.contains(_category) ? _category : null,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(c.icon, color: c.color, size: 20),
                            const SizedBox(width: 12),
                            Text(c.name),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (c) => setState(() => _category = c),
              validator: (v) => v == null ? 'Select a category' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(
                '${_date.day}/${_date.month}/${_date.year}',
              ),
              trailing: TextButton(onPressed: _pickDate, child: const Text('Change')),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recurring transaction'),
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_isEditing ? 'Save Changes' : 'Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}

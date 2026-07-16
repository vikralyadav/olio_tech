import 'package:flutter/material.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/entities/category.dart';
import '../../../core/entities/subscription.dart';
import '../../../core/utils/formatters.dart';
import '../cubit/subscription_cubit.dart';

class SubscriptionFormPage extends StatefulWidget {
  final SubscriptionCubit cubit;
  final Subscription? initial;

  const SubscriptionFormPage({super.key, required this.cubit, this.initial});

  @override
  State<SubscriptionFormPage> createState() => _SubscriptionFormPageState();
}

class _SubscriptionFormPageState extends State<SubscriptionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late BillingCycle _cycle;
  late SubscriptionStatus _status;
  late DateTime _nextBilling;
  Category? _category;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  List<Category> get _expenseCategories =>
      MockData.categories.where((c) => c.type == CategoryType.expense).toList();

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    _nameController = TextEditingController(text: s?.name ?? '');
    _amountController =
        TextEditingController(text: s != null ? s.amount.toString() : '');
    _noteController = TextEditingController(text: s?.note ?? '');
    _cycle = s?.cycle ?? BillingCycle.monthly;
    _status = s?.status ?? SubscriptionStatus.active;
    _nextBilling =
        s?.nextBillingDate ?? DateTime.now().add(const Duration(days: 30));
    _category = s != null
        ? _expenseCategories.firstWhere((c) => c.id == s.categoryId,
            orElse: () => _expenseCategories.first)
        : _expenseCategories.firstWhere((c) => c.id == 'cat_17',
            orElse: () => _expenseCategories.first);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextBilling,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _nextBilling = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _category == null) return;
    setState(() => _saving = true);

    final base = widget.initial;
    final subscription = Subscription(
      id: base?.id ?? 'sub_${DateTime.now().microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      cycle: _cycle,
      startDate: base?.startDate ?? DateTime.now(),
      nextBillingDate: _nextBilling,
      categoryId: _category!.id,
      categoryName: _category!.name,
      status: _status,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    if (_isEditing) {
      await widget.cubit.edit(subscription);
    } else {
      await widget.cubit.create(subscription);
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(_isEditing ? 'Subscription updated' : 'Subscription added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(_isEditing ? 'Edit Subscription' : 'New Subscription')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.subscriptions),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
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
                if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BillingCycle>(
              initialValue: _cycle,
              decoration: const InputDecoration(
                labelText: 'Billing Cycle',
                prefixIcon: Icon(Icons.repeat),
              ),
              items: BillingCycle.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(AppFormatters.billingCycle(c.name)),
                      ))
                  .toList(),
              onChanged: (c) => setState(() => _cycle = c!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Category>(
              initialValue: _category,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: _expenseCategories
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
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SubscriptionStatus>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: SubscriptionStatus.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.name[0].toUpperCase() + s.name.substring(1)),
                      ))
                  .toList(),
              onChanged: (s) => setState(() => _status = s!),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: const Text('Next billing date'),
              subtitle: Text(AppFormatters.date(_nextBilling)),
              trailing:
                  TextButton(onPressed: _pickDate, child: const Text('Change')),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: Text(_isEditing ? 'Save Changes' : 'Add Subscription'),
            ),
          ],
        ),
      ),
    );
  }
}

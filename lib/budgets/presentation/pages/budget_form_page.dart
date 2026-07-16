import 'package:flutter/material.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/entities/budget.dart';
import '../../../core/entities/category.dart';
import '../cubit/budget_cubit.dart';

class BudgetFormPage extends StatefulWidget {
  final BudgetCubit cubit;
  final Budget? initial;

  const BudgetFormPage({super.key, required this.cubit, this.initial});

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _limitController;
  Category? _category;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  List<Category> get _expenseCategories =>
      MockData.categories.where((c) => c.type == CategoryType.expense).toList();

  @override
  void initState() {
    super.initState();
    final b = widget.initial;
    _limitController =
        TextEditingController(text: b != null ? b.limit.toString() : '');
    _category = b != null
        ? _expenseCategories.firstWhere((c) => c.id == b.categoryId,
            orElse: () => _expenseCategories.first)
        : _expenseCategories.first;
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _category == null) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    final base = widget.initial;
    final budget = Budget(
      id: base?.id ?? 'bud_${DateTime.now().microsecondsSinceEpoch}',
      categoryId: _category!.id,
      categoryName: _category!.name,
      limit: double.parse(_limitController.text.trim()),
      spent: base?.spent ?? 0,
      startDate: base?.startDate ?? DateTime(now.year, now.month, 1),
      endDate: base?.endDate ?? DateTime(now.year, now.month + 1, 0),
      isActive: base?.isActive ?? true,
    );

    if (_isEditing) {
      await widget.cubit.edit(budget);
    } else {
      await widget.cubit.create(budget);
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Budget updated' : 'Budget created')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Budget' : 'New Budget')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
              validator: (v) => v == null ? 'Select a category' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _limitController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monthly Limit',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Limit is required';
                final parsed = double.tryParse(v.trim());
                if (parsed == null) return 'Enter a valid number';
                if (parsed <= 0) return 'Limit must be greater than 0';
                return null;
              },
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
              label: Text(_isEditing ? 'Save Changes' : 'Create Budget'),
            ),
          ],
        ),
      ),
    );
  }
}

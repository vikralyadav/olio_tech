import 'package:flutter/material.dart';

import '../../../core/entities/budget.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/category_avatar.dart';
import '../../../core/widgets/progress_bar.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback? onTap;

  const BudgetCard({super.key, required this.budget, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final over = budget.isOverBudget;
    final near = !over && budget.percentage >= 0.85;
    final color = over
        ? scheme.error
        : near
            ? Colors.orange
            : CategoryVisuals.colorFor(budget.categoryId);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoryAvatar(categoryId: budget.categoryId, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(budget.categoryName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(
                          '${AppFormatters.currency(budget.spent)} of ${AppFormatters.currency(budget.limit)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppFormatters.percentage(budget.percentage),
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppProgressBar(value: budget.percentage, color: color),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    over
                        ? 'Over by ${AppFormatters.currency(budget.spent - budget.limit)}'
                        : '${AppFormatters.currency(budget.remaining)} left',
                    style: TextStyle(
                        color: over ? scheme.error : scheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                  if (near || over)
                    Icon(
                      over ? Icons.error_outline : Icons.warning_amber_rounded,
                      size: 16,
                      color: color,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Displays a monetary amount coloured for income (+) / expense (-).
class AmountText extends StatelessWidget {
  final double amount;
  final bool isExpense;
  final bool showSign;
  final TextStyle? style;
  final bool colored;

  const AmountText({
    super.key,
    required this.amount,
    required this.isExpense,
    this.showSign = true,
    this.style,
    this.colored = true,
  });

  @override
  Widget build(BuildContext context) {
    final sign = showSign ? (isExpense ? '- ' : '+ ') : '';
    final color = isExpense ? AppTheme.expenseColor : AppTheme.incomeColor;
    final base = style ??
        Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w600);
    return Text(
      '$sign${AppFormatters.currency(amount)}',
      style: base?.copyWith(color: colored ? color : base.color),
    );
  }
}

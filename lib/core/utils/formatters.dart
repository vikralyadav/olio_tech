import 'package:flutter/material.dart';

class AppFormatters {
  static String currency(double amount, {String symbol = '\$'}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
    }

    return '${isNegative ? '-' : ''}$symbol${buffer.toString()}.$decPart';
  }

  static String shortCurrency(double amount, {String symbol = '\$'}) {
    if (amount.abs() >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  static String date(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String shortDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  static String monthYear(int month, int year) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[month - 1]} $year';
  }

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }

  static String percentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static String billingCycle(String cycle) {
    switch (cycle) {
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      case 'yearly':
        return 'Yearly';
      default:
        return cycle;
    }
  }

  static Color getCategoryColor(int index) {
    final colors = [
      const Color(0xFF6750A4),
      const Color(0xFF4CAF50),
      const Color(0xFFEF5350),
      const Color(0xFFFF9800),
      const Color(0xFF2196F3),
      const Color(0xFF9C27B0),
      const Color(0xFF009688),
      const Color(0xFFE91E63),
      const Color(0xFF795548),
      const Color(0xFF607D8B),
      const Color(0xFFFF5722),
      const Color(0xFF3F51B5),
      const Color(0xFFCDDC39),
      const Color(0xFF00BCD4),
      const Color(0xFFFFC107),
      const Color(0xFF8BC34A),
      const Color(0xFF673AB7),
      const Color(0xFFFF4081),
      const Color(0xFF00E676),
      const Color(0xFFFF6E40),
    ];
    return colors[index % colors.length];
  }
}

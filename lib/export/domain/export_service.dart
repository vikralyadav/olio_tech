import '../../core/entities/transaction.dart';
import '../../core/utils/formatters.dart';

enum ExportFormat { csv, json, summary }

extension ExportFormatX on ExportFormat {
  String get label {
    switch (this) {
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.json:
        return 'JSON';
      case ExportFormat.summary:
        return 'Summary';
    }
  }

  String get extension {
    switch (this) {
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.json:
        return 'json';
      case ExportFormat.summary:
        return 'txt';
    }
  }
}

/// Pure formatter that serialises transactions to the chosen format.
class ExportService {
  const ExportService();

  String build(List<Transaction> txns, ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return _csv(txns);
      case ExportFormat.json:
        return _json(txns);
      case ExportFormat.summary:
        return _summary(txns);
    }
  }

  String _csv(List<Transaction> txns) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Title,Category,Type,Amount,Recurring,Note');
    for (final t in txns) {
      final note = (t.note ?? '').replaceAll(',', ';').replaceAll('\n', ' ');
      buffer.writeln(
        '${t.date.toIso8601String().split('T').first},'
        '"${t.title}",'
        '${t.categoryName},'
        '${t.type.name},'
        '${t.amount.toStringAsFixed(2)},'
        '${t.isRecurring},'
        '"$note"',
      );
    }
    return buffer.toString();
  }

  String _json(List<Transaction> txns) {
    final entries = txns.map((t) {
      return '  {\n'
          '    "date": "${t.date.toIso8601String()}",\n'
          '    "title": "${t.title}",\n'
          '    "category": "${t.categoryName}",\n'
          '    "type": "${t.type.name}",\n'
          '    "amount": ${t.amount.toStringAsFixed(2)},\n'
          '    "recurring": ${t.isRecurring}\n'
          '  }';
    }).join(',\n');
    return '[\n$entries\n]';
  }

  String _summary(List<Transaction> txns) {
    final income = txns
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final expense = txns
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);

    final byCategory = <String, double>{};
    for (final t in txns.where((t) => t.type == TransactionType.expense)) {
      byCategory[t.categoryName] =
          (byCategory[t.categoryName] ?? 0) + t.amount;
    }
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final buffer = StringBuffer();
    buffer.writeln('OLIO FINANCE — TRANSACTION SUMMARY');
    buffer.writeln('=' * 38);
    buffer.writeln('Total transactions : ${txns.length}');
    buffer.writeln('Total income       : ${AppFormatters.currency(income)}');
    buffer.writeln('Total expense      : ${AppFormatters.currency(expense)}');
    buffer.writeln(
        'Net balance        : ${AppFormatters.currency(income - expense)}');
    buffer.writeln('');
    buffer.writeln('SPENDING BY CATEGORY');
    buffer.writeln('-' * 38);
    for (final e in sorted) {
      buffer.writeln(
          '${e.key.padRight(22)} ${AppFormatters.currency(e.value)}');
    }
    return buffer.toString();
  }
}

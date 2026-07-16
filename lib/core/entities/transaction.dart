import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class Transaction extends Equatable {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String categoryName;
  final TransactionType type;
  final String? note;
  final String? receiptId;
  final bool isRecurring;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.categoryName,
    required this.type,
    this.note,
    this.receiptId,
    this.isRecurring = false,
  });

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    String? categoryName,
    TransactionType? type,
    String? note,
    String? receiptId,
    bool? isRecurring,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      type: type ?? this.type,
      note: note ?? this.note,
      receiptId: receiptId ?? this.receiptId,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        date,
        categoryId,
        categoryName,
        type,
        note,
        receiptId,
        isRecurring,
      ];
}

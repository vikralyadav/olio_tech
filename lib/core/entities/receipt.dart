import 'package:equatable/equatable.dart';

class ReceiptItem extends Equatable {
  final String name;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [name, quantity, unitPrice, totalPrice];
}

class Receipt extends Equatable {
  final String id;
  final String merchantName;
  final DateTime date;
  final double totalAmount;
  final double? taxAmount;
  final String? categoryId;
  final String? categoryName;
  final List<ReceiptItem> items;
  final String? imagePath;
  final String? transactionId;
  final String? note;

  const Receipt({
    required this.id,
    required this.merchantName,
    required this.date,
    required this.totalAmount,
    this.taxAmount,
    this.categoryId,
    this.categoryName,
    this.items = const [],
    this.imagePath,
    this.transactionId,
    this.note,
  });

  Receipt copyWith({
    String? id,
    String? merchantName,
    DateTime? date,
    double? totalAmount,
    double? taxAmount,
    String? categoryId,
    String? categoryName,
    List<ReceiptItem>? items,
    String? imagePath,
    String? transactionId,
    String? note,
  }) {
    return Receipt(
      id: id ?? this.id,
      merchantName: merchantName ?? this.merchantName,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      items: items ?? this.items,
      imagePath: imagePath ?? this.imagePath,
      transactionId: transactionId ?? this.transactionId,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [
        id,
        merchantName,
        date,
        totalAmount,
        taxAmount,
        categoryId,
        categoryName,
        items,
        imagePath,
        transactionId,
        note,
      ];
}

import 'dart:math';

import '../../../core/data/app_database.dart';
import '../../../core/entities/receipt.dart';

abstract class ReceiptLocalDataSource {
  Future<List<Receipt>> getAll();
  Future<Receipt> add(Receipt receipt);
  Future<void> delete(String id);
  Future<Receipt> scan();
}

class ReceiptLocalDataSourceImpl implements ReceiptLocalDataSource {
  final AppDatabase db;
  ReceiptLocalDataSourceImpl(this.db);

  static const _merchants = [
    'Walmart', 'Target', 'Whole Foods', 'Trader Joe\'s', 'Costco',
    'Starbucks', 'CVS Pharmacy', 'Best Buy', 'Home Depot', 'Chipotle',
  ];

  static const _itemNames = [
    'Organic Milk', 'Whole Wheat Bread', 'Free-Range Eggs', 'Bananas',
    'Chicken Breast', 'Greek Yogurt', 'Olive Oil', 'Cheddar Cheese',
    'Ground Coffee', 'Orange Juice', 'Pasta', 'Tomato Sauce', 'Avocados',
    'Paper Towels', 'Dish Soap', 'Shampoo', 'Toothpaste', 'Almonds',
  ];

  @override
  Future<List<Receipt>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = List<Receipt>.from(db.receipts)
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<Receipt> add(Receipt receipt) async {
    await Future.delayed(const Duration(milliseconds: 200));
    db.receipts.insert(0, receipt);
    return receipt;
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    db.receipts.removeWhere((r) => r.id == id);
  }

  /// Simulated OCR: generates a realistic parsed receipt after a scan delay.
  @override
  Future<Receipt> scan() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    final rand = Random(DateTime.now().millisecondsSinceEpoch);
    final merchant = _merchants[rand.nextInt(_merchants.length)];
    final numItems = 3 + rand.nextInt(5);

    final items = <ReceiptItem>[];
    double subtotal = 0;
    final usedNames = <String>{};
    for (int i = 0; i < numItems; i++) {
      String name;
      do {
        name = _itemNames[rand.nextInt(_itemNames.length)];
      } while (usedNames.contains(name) && usedNames.length < _itemNames.length);
      usedNames.add(name);

      final qty = 1 + rand.nextInt(3);
      final unit = double.parse(
          (1.5 + rand.nextInt(20) + rand.nextDouble()).toStringAsFixed(2));
      final total = double.parse((unit * qty).toStringAsFixed(2));
      subtotal += total;
      items.add(ReceiptItem(
        name: name,
        quantity: qty,
        unitPrice: unit,
        totalPrice: total,
      ));
    }

    final tax = double.parse((subtotal * 0.08).toStringAsFixed(2));
    final receipt = Receipt(
      id: 'rcp_${DateTime.now().microsecondsSinceEpoch}',
      merchantName: merchant,
      date: DateTime.now(),
      totalAmount: double.parse((subtotal + tax).toStringAsFixed(2)),
      taxAmount: tax,
      categoryId: 'cat_13',
      categoryName: 'Groceries',
      items: items,
      note: 'Scanned receipt',
    );
    return receipt;
  }
}

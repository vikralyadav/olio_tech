import '../../../core/entities/receipt.dart';

abstract class ReceiptRepository {
  Future<List<Receipt>> getAll();
  Future<Receipt> add(Receipt receipt);
  Future<void> delete(String id);

  /// Simulates OCR scanning, returning a realistic parsed receipt.
  Future<Receipt> scan();
}

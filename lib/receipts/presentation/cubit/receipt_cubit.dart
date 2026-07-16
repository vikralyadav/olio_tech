import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/receipt.dart';
import '../../../core/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/repositories/receipt_repository.dart';
import 'receipt_state.dart';

class ReceiptCubit extends Cubit<ReceiptState> {
  final ReceiptRepository receiptRepository;
  final TransactionRepository transactionRepository;

  ReceiptCubit({
    required this.receiptRepository,
    required this.transactionRepository,
  }) : super(const ReceiptState());

  Future<void> load() async {
    emit(state.copyWith(status: ReceiptStatus.loading));
    try {
      final list = await receiptRepository.getAll();
      emit(state.copyWith(status: ReceiptStatus.loaded, receipts: list));
    } catch (e) {
      emit(state.copyWith(
          status: ReceiptStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> refresh() => load();

  /// Runs the mocked OCR scan.
  Future<void> scan() async {
    emit(state.copyWith(scanStatus: ScanStatus.scanning, clearScanned: true));
    try {
      final receipt = await receiptRepository.scan();
      emit(state.copyWith(scanStatus: ScanStatus.scanned, scanned: receipt));
    } catch (e) {
      emit(state.copyWith(
          scanStatus: ScanStatus.idle, errorMessage: e.toString()));
    }
  }

  void discardScan() =>
      emit(state.copyWith(scanStatus: ScanStatus.idle, clearScanned: true));

  /// Saves a scanned receipt and creates a matching expense transaction.
  Future<void> saveScanned(Receipt receipt) async {
    await receiptRepository.add(receipt);
    await _createTransaction(receipt);
    emit(state.copyWith(scanStatus: ScanStatus.idle, clearScanned: true));
    await load();
  }

  Future<void> convertToTransaction(Receipt receipt) async {
    await _createTransaction(receipt);
  }

  Future<void> _createTransaction(Receipt receipt) async {
    final transaction = Transaction(
      id: 'txn_${DateTime.now().microsecondsSinceEpoch}',
      title: receipt.merchantName,
      amount: receipt.totalAmount,
      date: receipt.date,
      categoryId: receipt.categoryId ?? 'cat_13',
      categoryName: receipt.categoryName ?? 'Groceries',
      type: TransactionType.expense,
      note: 'From scanned receipt',
      receiptId: receipt.id,
    );
    await transactionRepository.add(transaction);
  }

  Future<void> remove(String id) async {
    await receiptRepository.delete(id);
    await load();
  }
}

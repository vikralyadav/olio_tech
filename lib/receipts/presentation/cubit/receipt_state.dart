import 'package:equatable/equatable.dart';

import '../../../core/entities/receipt.dart';

enum ReceiptStatus { initial, loading, loaded, error }

enum ScanStatus { idle, scanning, scanned }

class ReceiptState extends Equatable {
  final ReceiptStatus status;
  final ScanStatus scanStatus;
  final List<Receipt> receipts;
  final Receipt? scanned;
  final String? errorMessage;

  const ReceiptState({
    this.status = ReceiptStatus.initial,
    this.scanStatus = ScanStatus.idle,
    this.receipts = const [],
    this.scanned,
    this.errorMessage,
  });

  double get totalScanned =>
      receipts.fold(0.0, (s, r) => s + r.totalAmount);

  ReceiptState copyWith({
    ReceiptStatus? status,
    ScanStatus? scanStatus,
    List<Receipt>? receipts,
    Receipt? scanned,
    bool clearScanned = false,
    String? errorMessage,
  }) {
    return ReceiptState(
      status: status ?? this.status,
      scanStatus: scanStatus ?? this.scanStatus,
      receipts: receipts ?? this.receipts,
      scanned: clearScanned ? null : (scanned ?? this.scanned),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, scanStatus, receipts, scanned, errorMessage];
}

import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Outcome of recording a payment and optionally building the receipt PDF.
class RecordPaymentResult extends Equatable {
  /// Creates the result.
  const RecordPaymentResult({
    required this.receiptNo,
    required this.status,
    required this.shareMessage,
    this.pdfBytes,
  });

  /// Assigned receipt number.
  final String receiptNo;

  /// Payment status after record (typically paid).
  final String status;

  /// PDF bytes when receipt delivery is enabled; otherwise null.
  final Uint8List? pdfBytes;

  /// WhatsApp-style message from the user template and payment data.
  final String shareMessage;

  @override
  List<Object?> get props =>
      <Object?>[receiptNo, status, pdfBytes, shareMessage];
}

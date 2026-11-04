import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Outcome of recording a payment and building the receipt PDF locally.
class RecordPaymentResult extends Equatable {
  /// Creates the result.
  const RecordPaymentResult({
    required this.receiptNo,
    required this.status,
    required this.pdfBytes,
  });

  /// Assigned receipt number.
  final String receiptNo;

  /// Payment status after record (typically paid).
  final String status;

  /// PDF bytes to share or preview.
  final Uint8List pdfBytes;

  @override
  List<Object?> get props => <Object?>[receiptNo, status, pdfBytes];
}

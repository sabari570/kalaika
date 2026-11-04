import 'package:equatable/equatable.dart';

/// Outcome of the generate-receipt Cloud Function.
class GenerateReceiptResult extends Equatable {
  /// Creates the result.
  const GenerateReceiptResult({
    required this.receiptNo,
    required this.receiptUrl,
    required this.status,
  });

  /// Assigned receipt number.
  final String receiptNo;

  /// Tokenized download URL for the PDF.
  final String receiptUrl;

  /// Payment status (typically paid).
  final String status;

  @override
  List<Object?> get props => <Object?>[receiptNo, receiptUrl, status];
}

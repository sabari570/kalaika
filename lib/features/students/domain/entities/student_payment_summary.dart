import 'package:equatable/equatable.dart';

/// Payment row shown on the student detail screen.
class StudentPaymentSummary extends Equatable {
  /// Creates a payment summary row.
  const StudentPaymentSummary({
    required this.id,
    required this.month,
    required this.amount,
    required this.mode,
    required this.receiptNo,
    required this.status,
    required this.receiptUrl,
    required this.receiptPath,
  });

  /// Payment document id.
  final String id;

  /// Month key, for example `2026-10`.
  final String month;

  /// Amount in rupees.
  final int amount;

  /// Payment mode value.
  final String mode;

  /// Receipt number if generated.
  final String? receiptNo;

  /// Payment status value.
  final String status;

  /// Receipt download URL if available.
  final String? receiptUrl;

  /// Cloud Storage path for the PDF.
  final String? receiptPath;

  @override
  List<Object?> get props => <Object?>[
    id,
    month,
    amount,
    mode,
    receiptNo,
    status,
    receiptUrl,
    receiptPath,
  ];
}

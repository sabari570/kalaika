import 'package:equatable/equatable.dart';

/// A monthly fee payment document.
class Payment extends Equatable {
  /// Creates a payment entity.
  const Payment({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.guardianName,
    required this.whatsappNumber,
    required this.month,
    required this.amount,
    required this.batchFee,
    required this.mode,
    required this.status,
    required this.receiptNo,
    required this.receiptUrl,
    required this.sentAt,
    required this.paidOn,
  });

  /// Document id.
  final String id;

  /// Student reference.
  final String studentId;

  /// Snapshot name.
  final String studentName;

  /// Snapshot guardian.
  final String? guardianName;

  /// Snapshot WhatsApp digits.
  final String whatsappNumber;

  /// Month key `yyyy-MM`.
  final String month;

  /// Amount in rupees.
  final int amount;

  /// Batch fee snapshot.
  final int batchFee;

  /// Payment mode value.
  final String mode;

  /// Status: paid, sent, or voided.
  final String status;

  /// Receipt number if generated.
  final String? receiptNo;

  /// Receipt URL if available.
  final String? receiptUrl;

  /// When the receipt was marked sent.
  final DateTime? sentAt;

  /// Paid date.
  final DateTime paidOn;

  @override
  List<Object?> get props => <Object?>[
    id,
    studentId,
    studentName,
    guardianName,
    whatsappNumber,
    month,
    amount,
    batchFee,
    mode,
    status,
    receiptNo,
    receiptUrl,
    sentAt,
    paidOn,
  ];
}

import 'package:equatable/equatable.dart';

/// A paid payment awaiting receipt delivery.
class PendingReceiptItem extends Equatable {
  /// Creates a pending receipt row.
  const PendingReceiptItem({
    required this.paymentId,
    required this.studentName,
    required this.guardianName,
    required this.branchId,
    required this.batchId,
    required this.batchName,
    required this.amount,
  });

  /// Payment document id.
  final String paymentId;

  /// Student name snapshot.
  final String studentName;

  /// Guardian name snapshot, if any.
  final String? guardianName;

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Batch display name.
  final String batchName;

  /// Recorded amount in rupees.
  final int amount;

  @override
  List<Object?> get props => <Object?>[
    paymentId,
    studentName,
    guardianName,
    branchId,
    batchId,
    batchName,
    amount,
  ];
}

import 'package:equatable/equatable.dart';
import 'package:feemanager/features/fees/domain/entities/payment.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';

/// Row payment display state.
enum FeeRowStatus {
  /// No payment document.
  unpaid,

  /// Paid, receipt pending.
  pendingSend,

  /// Receipt sent.
  sent,
}

/// List filter for the fee tracker.
enum FeeListFilter {
  /// All active students.
  all,

  /// No payment for the month.
  unpaid,

  /// Paid, receipt not sent.
  pendingSend,

  /// Receipt marked sent.
  sent,
}

/// One row in the monthly fee tracker.
class FeeRow extends Equatable {
  /// Creates a fee row.
  const FeeRow({
    required this.student,
    required this.payment,
    required this.displayStatus,
    required this.amount,
  });

  /// Active student in the batch.
  final Student student;

  /// Payment when recorded for the selected month.
  final Payment? payment;

  /// UI status for chips and controls.
  final FeeRowStatus displayStatus;

  /// Fee amount shown on the row.
  final int amount;

  @override
  List<Object?> get props => <Object?>[student, payment, displayStatus, amount];
}

import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/fees/domain/entities/record_payment_result.dart';
import 'package:feemanager/features/fees/domain/repositories/payment_repository.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';

/// Records a payment in Firestore and builds the receipt PDF on device.
class RecordPaymentAndReceipt
    implements UseCase<RecordPaymentResult, RecordPaymentParams> {
  /// Creates the use case.
  RecordPaymentAndReceipt(this._repository);

  final PaymentRepository _repository;

  @override
  Future<Result<RecordPaymentResult>> call(RecordPaymentParams params) {
    return _repository.recordPaymentAndReceipt(
      branchId: params.branchId,
      batchId: params.batchId,
      student: params.student,
      monthKey: params.monthKey,
      amount: params.amount,
      mode: params.mode,
      paidOn: params.paidOn,
      note: params.note,
    );
  }
}

/// Parameters for recording a payment and receipt.
class RecordPaymentParams {
  /// Creates parameters.
  const RecordPaymentParams({
    required this.branchId,
    required this.batchId,
    required this.student,
    required this.monthKey,
    required this.amount,
    required this.mode,
    required this.paidOn,
    this.note,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Student to pay for.
  final Student student;

  /// Month key (`yyyy-MM`).
  final String monthKey;

  /// Amount in whole rupees.
  final int amount;

  /// Payment mode stored on the payment document.
  final String mode;

  /// Date the fee was received.
  final DateTime paidOn;

  /// Optional note on the receipt.
  final String? note;
}

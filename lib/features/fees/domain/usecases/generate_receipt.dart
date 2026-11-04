import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/fees/domain/entities/generate_receipt_result.dart';
import 'package:feemanager/features/fees/domain/repositories/payment_repository.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';

/// Records a payment and generates a PDF receipt on the server.
class GenerateReceipt
    implements UseCase<GenerateReceiptResult, GenerateReceiptParams> {
  /// Creates the use case.
  GenerateReceipt(this._repository);

  final PaymentRepository _repository;

  @override
  Future<Result<GenerateReceiptResult>> call(GenerateReceiptParams params) {
    return _repository.generateReceipt(
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

/// Parameters for [GenerateReceipt].
class GenerateReceiptParams {
  /// Creates generate-receipt parameters.
  const GenerateReceiptParams({
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

import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/fees/domain/repositories/payment_repository.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';

/// Debug-only paid payment creator (M5).
class DebugCreatePaidPayment
    implements UseCase<void, DebugCreatePaidPaymentParams> {
  /// Creates the use case.
  DebugCreatePaidPayment(this._repository);

  final PaymentRepository _repository;

  @override
  Future<Result<void>> call(DebugCreatePaidPaymentParams params) {
    return _repository.debugCreatePaidPayment(
      branchId: params.branchId,
      batchId: params.batchId,
      student: params.student,
      monthKey: params.monthKey,
      batchDefaultFee: params.batchDefaultFee,
    );
  }
}

/// Parameters for [DebugCreatePaidPayment].
class DebugCreatePaidPaymentParams {
  /// Creates debug payment parameters.
  const DebugCreatePaidPaymentParams({
    required this.branchId,
    required this.batchId,
    required this.student,
    required this.monthKey,
    required this.batchDefaultFee,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Student to pay for.
  final Student student;

  /// Month key.
  final String monthKey;

  /// Batch default fee snapshot.
  final int batchDefaultFee;
}

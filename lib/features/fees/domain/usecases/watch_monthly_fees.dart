import 'package:feemanager/features/fees/domain/entities/payment.dart';
import 'package:feemanager/features/fees/domain/repositories/payment_repository.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';

/// Streams active students for the fee tracker.
class WatchActiveStudentsForFees {
  /// Creates the use case.
  WatchActiveStudentsForFees(this._repository);

  final PaymentRepository _repository;

  /// Subscribes to active students.
  Stream<List<Student>> call(WatchFeesParams params) {
    return _repository.watchActiveStudents(
      params.branchId,
      params.batchId,
    );
  }
}

/// Streams payments for one month.
class WatchMonthlyPayments {
  /// Creates the use case.
  WatchMonthlyPayments(this._repository);

  final PaymentRepository _repository;

  /// Subscribes to batch payments for [WatchMonthlyPaymentsParams.monthKey].
  Stream<List<Payment>> call(WatchMonthlyPaymentsParams params) {
    return _repository.watchPaymentsForMonth(
      params.branchId,
      params.batchId,
      params.monthKey,
    );
  }
}

/// Shared branch and batch ids.
class WatchFeesParams {
  /// Creates fee watch parameters.
  const WatchFeesParams({
    required this.branchId,
    required this.batchId,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;
}

/// Month-scoped payment watch parameters.
class WatchMonthlyPaymentsParams extends WatchFeesParams {
  /// Creates payment watch parameters.
  const WatchMonthlyPaymentsParams({
    required super.branchId,
    required super.batchId,
    required this.monthKey,
  });

  /// Month key `yyyy-MM`.
  final String monthKey;
}

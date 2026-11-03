import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/fees/domain/entities/payment.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';

/// Payment reads and debug writes for the fee tracker.
abstract class PaymentRepository {
  /// Streams active students in a batch ordered by name.
  Stream<List<Student>> watchActiveStudents(
    String branchId,
    String batchId,
  );

  /// Streams payments for a batch month (`yyyy-MM`).
  Stream<List<Payment>> watchPaymentsForMonth(
    String branchId,
    String batchId,
    String monthKey,
  );

  /// Creates a paid payment document for debugging (M5 only).
  Future<Result<void>> debugCreatePaidPayment({
    required String branchId,
    required String batchId,
    required Student student,
    required String monthKey,
    required int batchDefaultFee,
  });
}

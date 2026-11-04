import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/fees/domain/entities/generate_receipt_result.dart';
import 'package:feemanager/features/fees/domain/entities/payment.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';

/// Payment reads and receipt generation for the fee tracker.
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

  /// Creates a paid payment and PDF receipt via Cloud Functions.
  Future<Result<GenerateReceiptResult>> generateReceipt({
    required String branchId,
    required String batchId,
    required Student student,
    required String monthKey,
    required int amount,
    required String mode,
    required DateTime paidOn,
    String? note,
  });
}

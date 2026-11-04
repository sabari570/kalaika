import 'dart:typed_data';

import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/fees/domain/entities/payment.dart';
import 'package:feemanager/features/fees/domain/entities/record_payment_result.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';

/// Payment reads and client-side receipt actions for the fee tracker.
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

  /// Creates a paid payment, updates rollups, and returns PDF bytes.
  Future<Result<RecordPaymentResult>> recordPaymentAndReceipt({
    required String branchId,
    required String batchId,
    required Student student,
    required String monthKey,
    required int amount,
    required String mode,
    required DateTime paidOn,
    String? note,
  });

  /// Regenerates PDF bytes for an existing payment.
  Future<Result<Uint8List>> buildReceiptPdf({
    required String branchId,
    required String batchId,
    required String paymentId,
    required Student student,
  });

  /// Marks a paid payment as sent.
  Future<Result<void>> markReceiptSent({
    required String branchId,
    required String batchId,
    required String paymentId,
  });

  /// Voids a payment and reverses rollups.
  Future<Result<void>> voidPayment({
    required String branchId,
    required String batchId,
    required String paymentId,
  });
}

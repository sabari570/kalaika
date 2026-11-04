import 'dart:typed_data';

import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/fees/domain/repositories/payment_repository.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';

/// Marks a payment as sent after the user shares the receipt.
class MarkReceiptSent implements UseCase<void, MarkReceiptSentParams> {
  /// Creates the use case.
  MarkReceiptSent(this._repository);

  final PaymentRepository _repository;

  @override
  Future<Result<void>> call(MarkReceiptSentParams params) {
    return _repository.markReceiptSent(
      branchId: params.branchId,
      batchId: params.batchId,
      paymentId: params.paymentId,
    );
  }
}

/// Parameters for [MarkReceiptSent].
class MarkReceiptSentParams {
  /// Creates parameters.
  const MarkReceiptSentParams({
    required this.branchId,
    required this.batchId,
    required this.paymentId,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Payment document id.
  final String paymentId;
}

/// Regenerates receipt PDF bytes from Firestore payment data.
class BuildReceiptPdf implements UseCase<Uint8List, BuildReceiptPdfParams> {
  /// Creates the use case.
  BuildReceiptPdf(this._repository);

  final PaymentRepository _repository;

  @override
  Future<Result<Uint8List>> call(BuildReceiptPdfParams params) {
    return _repository.buildReceiptPdf(
      branchId: params.branchId,
      batchId: params.batchId,
      paymentId: params.paymentId,
      student: params.student,
    );
  }
}

/// Parameters for [BuildReceiptPdf].
class BuildReceiptPdfParams {
  /// Creates parameters.
  const BuildReceiptPdfParams({
    required this.branchId,
    required this.batchId,
    required this.paymentId,
    required this.student,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Payment document id.
  final String paymentId;

  /// Student entity for PDF context.
  final Student student;
}

/// Voids a recorded payment.
class VoidPayment implements UseCase<void, VoidPaymentParams> {
  /// Creates the use case.
  VoidPayment(this._repository);

  final PaymentRepository _repository;

  @override
  Future<Result<void>> call(VoidPaymentParams params) {
    return _repository.voidPayment(
      branchId: params.branchId,
      batchId: params.batchId,
      paymentId: params.paymentId,
    );
  }
}

/// Parameters for [VoidPayment].
class VoidPaymentParams {
  /// Creates parameters.
  const VoidPaymentParams({
    required this.branchId,
    required this.batchId,
    required this.paymentId,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Payment document id.
  final String paymentId;
}

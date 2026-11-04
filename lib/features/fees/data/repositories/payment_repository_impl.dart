import 'dart:typed_data';

import 'package:feemanager/core/error/exception_mapper.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/fees/data/datasources/payment_remote_datasource.dart';
import 'package:feemanager/features/fees/data/datasources/payment_write_datasource.dart';
import 'package:feemanager/features/fees/domain/entities/payment.dart';
import 'package:feemanager/features/fees/domain/entities/record_payment_result.dart';
import 'package:feemanager/features/fees/domain/repositories/payment_repository.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';

/// Firestore implementation of [PaymentRepository].
class PaymentRepositoryImpl implements PaymentRepository {
  /// Creates the repository.
  PaymentRepositoryImpl({
    required this.remoteDataSource,
    required this.writeDataSource,
  });

  final PaymentRemoteDataSource remoteDataSource;
  final PaymentWriteDataSource writeDataSource;

  @override
  Stream<List<Student>> watchActiveStudents(
    String branchId,
    String batchId,
  ) {
    return remoteDataSource.watchActiveStudents(branchId, batchId);
  }

  @override
  Stream<List<Payment>> watchPaymentsForMonth(
    String branchId,
    String batchId,
    String monthKey,
  ) {
    return remoteDataSource.watchPaymentsForMonth(
      branchId,
      batchId,
      monthKey,
    );
  }

  @override
  Future<Result<RecordPaymentResult>> recordPaymentAndReceipt({
    required String branchId,
    required String batchId,
    required Student student,
    required String monthKey,
    required int amount,
    required String mode,
    required DateTime paidOn,
    String? note,
  }) async {
    try {
      final result = await writeDataSource.recordPaymentAndReceipt(
        branchId: branchId,
        batchId: batchId,
        student: student,
        monthKey: monthKey,
        amount: amount,
        mode: mode,
        paidOn: paidOn,
        note: note,
      );
      return Success<RecordPaymentResult>(result);
    } on Object catch (error, stackTrace) {
      return Err<RecordPaymentResult>(
        ExceptionMapper.map(error, stackTrace),
      );
    }
  }

  @override
  Future<Result<Uint8List>> buildReceiptPdf({
    required String branchId,
    required String batchId,
    required String paymentId,
    required Student student,
  }) async {
    try {
      final bytes = await writeDataSource.buildReceiptPdf(
        branchId: branchId,
        batchId: batchId,
        paymentId: paymentId,
        student: student,
      );
      return Success<Uint8List>(bytes);
    } on Object catch (error, stackTrace) {
      return Err<Uint8List>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<String>> buildReceiptShareMessage({
    required String branchId,
    required String batchId,
    required String paymentId,
    required Student student,
  }) async {
    try {
      final message = await writeDataSource.buildReceiptShareMessage(
        branchId: branchId,
        batchId: batchId,
        paymentId: paymentId,
        student: student,
      );
      return Success<String>(message);
    } on Object catch (error, stackTrace) {
      return Err<String>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> markReceiptSent({
    required String branchId,
    required String batchId,
    required String paymentId,
  }) async {
    try {
      await writeDataSource.markReceiptSent(
        branchId: branchId,
        batchId: batchId,
        paymentId: paymentId,
      );
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return Err<void>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> voidPayment({
    required String branchId,
    required String batchId,
    required String paymentId,
  }) async {
    try {
      await writeDataSource.voidPayment(
        branchId: branchId,
        batchId: batchId,
        paymentId: paymentId,
      );
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return Err<void>(ExceptionMapper.map(error, stackTrace));
    }
  }
}

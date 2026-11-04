import 'package:feemanager/core/error/exception_mapper.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/fees/data/datasources/payment_functions_datasource.dart';
import 'package:feemanager/features/fees/data/datasources/payment_remote_datasource.dart';
import 'package:feemanager/features/fees/domain/entities/generate_receipt_result.dart';
import 'package:feemanager/features/fees/domain/entities/payment.dart';
import 'package:feemanager/features/fees/domain/repositories/payment_repository.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';

/// Firestore and Cloud Functions implementation of [PaymentRepository].
class PaymentRepositoryImpl implements PaymentRepository {
  /// Creates the repository.
  PaymentRepositoryImpl({
    required this.remoteDataSource,
    required this.functionsDataSource,
  });

  final PaymentRemoteDataSource remoteDataSource;
  final PaymentFunctionsDataSource functionsDataSource;

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
  Future<Result<GenerateReceiptResult>> generateReceipt({
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
      final result = await functionsDataSource.generateReceipt(
        branchId: branchId,
        batchId: batchId,
        studentId: student.id,
        monthKey: monthKey,
        amount: amount,
        mode: mode,
        paidOn: paidOn,
        note: note,
      );
      return Success<GenerateReceiptResult>(result);
    } on Object catch (error, stackTrace) {
      return Err<GenerateReceiptResult>(
        ExceptionMapper.map(error, stackTrace),
      );
    }
  }
}

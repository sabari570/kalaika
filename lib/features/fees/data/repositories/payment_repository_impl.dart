import 'package:feemanager/core/error/exception_mapper.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/utils/firebase_user_scope.dart';
import 'package:feemanager/features/fees/data/datasources/payment_remote_datasource.dart';
import 'package:feemanager/features/fees/domain/entities/payment.dart';
import 'package:feemanager/features/fees/domain/repositories/payment_repository.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';

/// Firestore implementation of [PaymentRepository].
class PaymentRepositoryImpl implements PaymentRepository {
  /// Creates the repository.
  PaymentRepositoryImpl({required this.remoteDataSource});

  final PaymentRemoteDataSource remoteDataSource;

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
  Future<Result<void>> debugCreatePaidPayment({
    required String branchId,
    required String batchId,
    required Student student,
    required String monthKey,
    required int batchDefaultFee,
  }) async {
    try {
      final uid = FirebaseUserScope.requireUid();
      await remoteDataSource.debugCreatePaidPayment(
        branchId: branchId,
        batchId: batchId,
        student: student,
        monthKey: monthKey,
        batchDefaultFee: batchDefaultFee,
        ownerId: uid,
      );
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return Err<void>(ExceptionMapper.map(error, stackTrace));
    }
  }
}

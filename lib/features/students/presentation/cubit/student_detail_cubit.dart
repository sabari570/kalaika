import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/students/domain/usecases/get_student.dart';
import 'package:feemanager/features/students/domain/usecases/student_import_usecases.dart';
import 'package:feemanager/features/students/presentation/cubit/student_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Loads student profile and payment history.
class StudentDetailCubit extends Cubit<StudentDetailState> {
  /// Creates the cubit.
  StudentDetailCubit({
    required this._getStudent,
    required this._getPaymentHistory,
  }) : super(const StudentDetailLoading());

  final GetStudent _getStudent;
  final GetStudentPaymentHistory _getPaymentHistory;

  /// Loads data for the route parameters.
  Future<void> started(
    String branchId,
    String batchId,
    String studentId,
  ) async {
    emit(const StudentDetailLoading());
    final studentResult = await _getStudent(
      GetStudentParams(
        branchId: branchId,
        batchId: batchId,
        studentId: studentId,
      ),
    );
    switch (studentResult) {
      case Success(:final value):
        final student = value;
        final paymentsResult = await _getPaymentHistory(
          GetStudentPaymentHistoryParams(
            branchId: branchId,
            batchId: batchId,
            studentId: studentId,
          ),
        );
        switch (paymentsResult) {
          case Success(:final value):
            emit(
              StudentDetailLoaded(
                student: student,
                payments: value,
              ),
            );
          case Err(:final failure):
            emit(StudentDetailFailure(failure.message));
        }
      case Err(:final failure):
        emit(StudentDetailFailure(failure.message));
    }
  }
}

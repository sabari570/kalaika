import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/students/domain/usecases/delete_student.dart';
import 'package:feemanager/features/students/domain/usecases/get_student.dart';
import 'package:feemanager/features/students/domain/usecases/student_import_usecases.dart';
import 'package:feemanager/features/students/presentation/cubit/student_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Loads student profile and payment history.
class StudentDetailCubit extends Cubit<StudentDetailState> {
  /// Creates the cubit.
  StudentDetailCubit({
    required this.getStudent,
    required this.getPaymentHistory,
    required this.deleteStudent,
  }) : super(const StudentDetailLoading());

  final GetStudent getStudent;
  final GetStudentPaymentHistory getPaymentHistory;
  final DeleteStudent deleteStudent;

  String? _branchId;
  String? _batchId;
  String? _studentId;

  /// Loads data for the route parameters.
  Future<void> started(
    String branchId,
    String batchId,
    String studentId,
  ) async {
    _branchId = branchId;
    _batchId = batchId;
    _studentId = studentId;
    emit(const StudentDetailLoading());
    final studentResult = await getStudent(
      GetStudentParams(
        branchId: branchId,
        batchId: batchId,
        studentId: studentId,
      ),
    );
    switch (studentResult) {
      case Success(:final value):
        final student = value;
        final paymentsResult = await getPaymentHistory(
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

  /// Permanently removes the loaded student.
  ///
  /// Returns an error message when deletion fails.
  Future<String?> deleteCurrentStudent() async {
    final branchId = _branchId;
    final batchId = _batchId;
    final studentId = _studentId;
    if (branchId == null || batchId == null || studentId == null) {
      return null;
    }
    emit(const StudentDetailDeleting());
    final result = await deleteStudent(
      DeleteStudentParams(
        branchId: branchId,
        batchId: batchId,
        studentId: studentId,
      ),
    );
    switch (result) {
      case Success():
        emit(const StudentDetailRemoved());
        return null;
      case Err(:final failure):
        await started(branchId, batchId, studentId);
        return failure.message;
    }
  }
}

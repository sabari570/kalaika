import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/students/domain/repositories/student_repository.dart';

/// Permanently removes a student and their payments.
class DeleteStudent implements UseCase<void, DeleteStudentParams> {
  /// Creates the use case.
  DeleteStudent(this._repository);

  final StudentRepository _repository;

  @override
  Future<Result<void>> call(DeleteStudentParams params) {
    return _repository.deleteStudent(
      params.branchId,
      params.batchId,
      params.studentId,
    );
  }
}

/// Parameters for [DeleteStudent].
class DeleteStudentParams {
  /// Creates delete parameters.
  const DeleteStudentParams({
    required this.branchId,
    required this.batchId,
    required this.studentId,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Student id.
  final String studentId;
}

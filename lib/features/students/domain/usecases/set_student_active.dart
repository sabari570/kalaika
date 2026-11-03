import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/students/domain/repositories/student_repository.dart';

/// Activates or deactivates a student.
class SetStudentActive implements UseCase<void, SetStudentActiveParams> {
  /// Creates the use case.
  SetStudentActive(this._repository);

  final StudentRepository _repository;

  @override
  Future<Result<void>> call(SetStudentActiveParams params) {
    return _repository.setStudentActive(
      params.branchId,
      params.batchId,
      params.studentId,
      isActive: params.isActive,
    );
  }
}

/// Parameters for [SetStudentActive].
class SetStudentActiveParams {
  /// Creates active toggle parameters.
  const SetStudentActiveParams({
    required this.branchId,
    required this.batchId,
    required this.studentId,
    required this.isActive,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Student id.
  final String studentId;

  /// Desired active flag.
  final bool isActive;
}

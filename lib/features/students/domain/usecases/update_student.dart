import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:feemanager/features/students/domain/entities/student_draft.dart';
import 'package:feemanager/features/students/domain/repositories/student_repository.dart';

/// Updates an existing student.
class UpdateStudent implements UseCase<Student, UpdateStudentParams> {
  /// Creates the use case.
  UpdateStudent(this._repository);

  final StudentRepository _repository;

  @override
  Future<Result<Student>> call(UpdateStudentParams params) {
    return _repository.updateStudent(
      params.branchId,
      params.batchId,
      params.studentId,
      params.draft,
    );
  }
}

/// Parameters for [UpdateStudent].
class UpdateStudentParams {
  /// Creates update parameters.
  const UpdateStudentParams({
    required this.branchId,
    required this.batchId,
    required this.studentId,
    required this.draft,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Student id.
  final String studentId;

  /// Field values.
  final StudentDraft draft;
}

import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:feemanager/features/students/domain/entities/student_draft.dart';
import 'package:feemanager/features/students/domain/repositories/student_repository.dart';

/// Creates a student in a batch.
class CreateStudent implements UseCase<Student, CreateStudentParams> {
  /// Creates the use case.
  CreateStudent(this._repository);

  final StudentRepository _repository;

  @override
  Future<Result<Student>> call(CreateStudentParams params) {
    return _repository.createStudent(
      params.branchId,
      params.batchId,
      params.draft,
    );
  }
}

/// Parameters for [CreateStudent].
class CreateStudentParams {
  /// Creates student create parameters.
  const CreateStudentParams({
    required this.branchId,
    required this.batchId,
    required this.draft,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Field values.
  final StudentDraft draft;
}

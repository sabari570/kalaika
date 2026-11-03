import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:feemanager/features/students/domain/repositories/student_repository.dart';

/// Loads one student document.
class GetStudent implements UseCase<Student, GetStudentParams> {
  /// Creates the use case.
  GetStudent(this._repository);

  final StudentRepository _repository;

  @override
  Future<Result<Student>> call(GetStudentParams params) {
    return _repository.getStudent(
      params.branchId,
      params.batchId,
      params.studentId,
    );
  }
}

/// Parameters for [GetStudent].
class GetStudentParams {
  /// Creates lookup parameters.
  const GetStudentParams({
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

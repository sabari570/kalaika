import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:feemanager/features/students/domain/repositories/student_repository.dart';

/// Streams students for a batch.
class WatchStudents {
  /// Creates the use case.
  WatchStudents(this._repository);

  final StudentRepository _repository;

  /// Subscribes to student list updates.
  Stream<List<Student>> call(WatchStudentsParams params) {
    return _repository.watchStudents(params.branchId, params.batchId);
  }
}

/// Parameters for [WatchStudents].
class WatchStudentsParams {
  /// Creates watch parameters.
  const WatchStudentsParams({
    required this.branchId,
    required this.batchId,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;
}

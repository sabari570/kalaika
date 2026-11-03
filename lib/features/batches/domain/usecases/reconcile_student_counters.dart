import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/batches/domain/repositories/batch_repository.dart';

/// Realigns stored student counters with active students in Firestore.
class ReconcileStudentCounters {
  /// Creates the use case.
  ReconcileStudentCounters(this._repository);

  final BatchRepository _repository;

  /// Reconciles every batch under [branchId] and the branch total.
  Future<Result<void>> call(String branchId) {
    return _repository.reconcileStudentCounters(branchId);
  }
}

import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/batches/domain/repositories/batch_repository.dart';
import 'package:feemanager/features/batches/domain/usecases/delete_batch.dart';

/// Marks a batch as inactive.
class DeactivateBatch implements UseCase<void, DeleteBatchParams> {
  /// Creates the use case.
  DeactivateBatch(this._repository);

  final BatchRepository _repository;

  @override
  Future<Result<void>> call(DeleteBatchParams params) {
    return _repository.deactivateBatch(params.branchId, params.batchId);
  }
}

import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/batches/domain/repositories/batch_repository.dart';

/// Deletes a batch and all related students and payments.
class DeleteBatch implements UseCase<void, DeleteBatchParams> {
  /// Creates the use case.
  DeleteBatch(this._repository);

  final BatchRepository _repository;

  @override
  Future<Result<void>> call(DeleteBatchParams params) {
    return _repository.deleteBatch(params.branchId, params.batchId);
  }
}

/// Parameters for [DeleteBatch].
class DeleteBatchParams {
  /// Creates delete parameters.
  const DeleteBatchParams({required this.branchId, required this.batchId});

  /// Parent branch id.
  final String branchId;

  /// Batch document id.
  final String batchId;
}

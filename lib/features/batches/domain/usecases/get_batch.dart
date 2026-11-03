import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/batches/domain/repositories/batch_repository.dart';

/// Loads a batch by id.
class GetBatch implements UseCase<Batch, GetBatchParams> {
  /// Creates the use case.
  GetBatch(this._repository);

  final BatchRepository _repository;

  @override
  Future<Result<Batch>> call(GetBatchParams params) {
    return _repository.getBatch(params.branchId, params.batchId);
  }
}

/// Parameters for [GetBatch].
class GetBatchParams {
  /// Creates lookup parameters.
  const GetBatchParams({required this.branchId, required this.batchId});

  /// Parent branch id.
  final String branchId;

  /// Batch document id.
  final String batchId;
}

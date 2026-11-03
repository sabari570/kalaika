import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/batches/domain/entities/batch_draft.dart';
import 'package:feemanager/features/batches/domain/repositories/batch_repository.dart';

/// Updates an existing batch.
class UpdateBatch implements UseCase<Batch, UpdateBatchParams> {
  /// Creates the use case.
  UpdateBatch(this._repository);

  final BatchRepository _repository;

  @override
  Future<Result<Batch>> call(UpdateBatchParams params) {
    return _repository.updateBatch(
      params.branchId,
      params.batchId,
      params.draft,
    );
  }
}

/// Parameters for [UpdateBatch].
class UpdateBatchParams {
  /// Creates update parameters.
  const UpdateBatchParams({
    required this.branchId,
    required this.batchId,
    required this.draft,
  });

  /// Parent branch id.
  final String branchId;

  /// Batch document id.
  final String batchId;

  /// Updated values.
  final BatchDraft draft;
}

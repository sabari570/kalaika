import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/batches/domain/entities/batch_draft.dart';
import 'package:feemanager/features/batches/domain/repositories/batch_repository.dart';

/// Creates a batch under a branch.
class CreateBatch implements UseCase<Batch, CreateBatchParams> {
  /// Creates the use case.
  CreateBatch(this._repository);

  final BatchRepository _repository;

  @override
  Future<Result<Batch>> call(CreateBatchParams params) {
    return _repository.createBatch(params.branchId, params.draft);
  }
}

/// Parameters for [CreateBatch].
class CreateBatchParams {
  /// Creates batch create parameters.
  const CreateBatchParams({required this.branchId, required this.draft});

  /// Parent branch id.
  final String branchId;

  /// Batch field values.
  final BatchDraft draft;
}

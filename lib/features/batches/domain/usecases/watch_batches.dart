import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/batches/domain/repositories/batch_repository.dart';

/// Streams batches for a branch.
class WatchBatches {
  /// Creates the use case.
  WatchBatches(this._repository);

  final BatchRepository _repository;

  /// Subscribes to batch list updates.
  Stream<List<Batch>> call(String branchId) {
    return _repository.watchBatches(branchId);
  }
}

import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/batches/domain/entities/batch_draft.dart';

/// Batch persistence and queries.
abstract class BatchRepository {
  /// Live list of batches for a branch.
  Stream<List<Batch>> watchBatches(String branchId);

  /// Fetches a single batch.
  Future<Result<Batch>> getBatch(String branchId, String batchId);

  /// Creates a batch and increments branch batch count.
  Future<Result<Batch>> createBatch(String branchId, BatchDraft draft);

  /// Updates batch fields and optional fee propagation.
  Future<Result<Batch>> updateBatch(
    String branchId,
    String batchId,
    BatchDraft draft,
  );

  /// Deletes an empty batch and decrements branch batch count.
  Future<Result<void>> deleteBatch(String branchId, String batchId);

  /// Marks a batch inactive when students still exist.
  Future<Result<void>> deactivateBatch(String branchId, String batchId);

  /// Realigns batch and branch student counters with Firestore data.
  Future<Result<void>> reconcileStudentCounters(String branchId);
}

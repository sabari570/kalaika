import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/branches/domain/entities/branch_draft.dart';

/// Branch persistence and queries.
abstract class BranchRepository {
  /// Live list of branches for the signed-in teacher.
  Stream<List<Branch>> watchBranches();

  /// Fetches a single branch by id.
  Future<Result<Branch>> getBranch(String branchId);

  /// Creates a branch document.
  Future<Result<Branch>> createBranch(BranchDraft draft);

  /// Updates branch fields and denormalized batch names when renamed.
  Future<Result<Branch>> updateBranch(String branchId, BranchDraft draft);

  /// Deletes a branch when it has no batches.
  Future<Result<void>> deleteBranch(String branchId);
}

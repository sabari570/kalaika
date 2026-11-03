import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/branches/domain/entities/branch_draft.dart';
import 'package:feemanager/features/branches/domain/repositories/branch_repository.dart';

/// Updates a branch record.
class UpdateBranch implements UseCase<Branch, UpdateBranchParams> {
  /// Creates the use case.
  UpdateBranch(this._repository);

  final BranchRepository _repository;

  @override
  Future<Result<Branch>> call(UpdateBranchParams params) {
    return _repository.updateBranch(params.branchId, params.draft);
  }
}

/// Parameters for [UpdateBranch].
class UpdateBranchParams {
  /// Creates update parameters.
  const UpdateBranchParams({required this.branchId, required this.draft});

  /// Branch document id.
  final String branchId;

  /// Updated field values.
  final BranchDraft draft;
}

import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/branches/domain/repositories/branch_repository.dart';

/// Deletes an empty branch.
class DeleteBranch implements UseCase<void, String> {
  /// Creates the use case.
  DeleteBranch(this._repository);

  final BranchRepository _repository;

  @override
  Future<Result<void>> call(String branchId) {
    return _repository.deleteBranch(branchId);
  }
}

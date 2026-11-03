import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/branches/domain/repositories/branch_repository.dart';

/// Loads a branch by id.
class GetBranch implements UseCase<Branch, String> {
  /// Creates the use case.
  GetBranch(this._repository);

  final BranchRepository _repository;

  @override
  Future<Result<Branch>> call(String branchId) {
    return _repository.getBranch(branchId);
  }
}

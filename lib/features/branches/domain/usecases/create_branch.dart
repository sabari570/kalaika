import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/branches/domain/entities/branch_draft.dart';
import 'package:feemanager/features/branches/domain/repositories/branch_repository.dart';

/// Creates a branch record.
class CreateBranch implements UseCase<Branch, BranchDraft> {
  /// Creates the use case.
  CreateBranch(this._repository);

  final BranchRepository _repository;

  @override
  Future<Result<Branch>> call(BranchDraft params) {
    return _repository.createBranch(params);
  }
}

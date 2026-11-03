import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/branches/domain/repositories/branch_repository.dart';

/// Streams all branches for the signed-in teacher.
class WatchBranches {
  /// Creates the use case.
  WatchBranches(this._repository);

  final BranchRepository _repository;

  /// Subscribes to branch list updates.
  Stream<List<Branch>> call() {
    return _repository.watchBranches();
  }
}

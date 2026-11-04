import 'package:equatable/equatable.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';

/// Branch list screen states.
sealed class BranchListState extends Equatable {
  const BranchListState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Initial loading state.
final class BranchListLoading extends BranchListState {
  const BranchListLoading();
}

/// Branch list loaded.
final class BranchListLoaded extends BranchListState {
  const BranchListLoaded(
    this.branches, {
    this.deletingBranchId,
  });

  final List<Branch> branches;

  /// When set, a branch delete request is in progress.
  final String? deletingBranchId;

  @override
  List<Object?> get props => <Object?>[branches, deletingBranchId];
}

/// Load failure.
final class BranchListFailure extends BranchListState {
  const BranchListFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

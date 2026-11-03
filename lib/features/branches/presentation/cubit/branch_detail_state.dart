import 'package:equatable/equatable.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';

/// Branch detail screen states.
sealed class BranchDetailState extends Equatable {
  const BranchDetailState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loading branch header.
final class BranchDetailLoading extends BranchDetailState {
  const BranchDetailLoading();
}

/// Branch and batches visible.
final class BranchDetailLoaded extends BranchDetailState {
  const BranchDetailLoaded({
    required this.branch,
    required this.batches,
  });

  final Branch branch;
  final List<Batch> batches;

  @override
  List<Object?> get props => <Object?>[branch, batches];
}

/// Failed to load branch.
final class BranchDetailFailure extends BranchDetailState {
  const BranchDetailFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

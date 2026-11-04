import 'dart:async';

import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/branches/domain/usecases/delete_branch.dart';
import 'package:feemanager/features/branches/domain/usecases/watch_branches.dart';
import 'package:feemanager/features/branches/presentation/cubit/branch_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Loads and maintains the branches tab list.
class BranchListCubit extends Cubit<BranchListState> {
  /// Creates the cubit.
  BranchListCubit({
    required this._watchBranches,
    required this._deleteBranch,
  }) : super(const BranchListLoading());

  final WatchBranches _watchBranches;
  final DeleteBranch _deleteBranch;
  StreamSubscription<List<Branch>>? _subscription;

  /// Starts listening to branch updates.
  void started() {
    unawaited(_subscription?.cancel());
    _subscription = _watchBranches().listen(
      (branches) => emit(BranchListLoaded(branches)),
      onError: (_) => emit(
        const BranchListFailure(AppStrings.unknownError),
      ),
    );
  }

  /// Deletes a branch when allowed.
  Future<Result<void>> deleteBranch(String branchId) async {
    final current = state;
    if (current is BranchListLoaded) {
      emit(
        BranchListLoaded(
          current.branches,
          deletingBranchId: branchId,
        ),
      );
    }
    final result = await _deleteBranch(branchId);
    if (current is BranchListLoaded && result is Err<void>) {
      emit(BranchListLoaded(current.branches));
    }
    return result;
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}

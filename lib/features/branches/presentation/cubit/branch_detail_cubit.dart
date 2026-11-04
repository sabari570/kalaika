import 'dart:async';

import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/batches/domain/usecases/reconcile_student_counters.dart';
import 'package:feemanager/features/batches/domain/usecases/watch_batches.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/branches/domain/usecases/get_branch.dart';
import 'package:feemanager/features/branches/presentation/cubit/branch_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Branch header and batch list for a single branch.
class BranchDetailCubit extends Cubit<BranchDetailState> {
  /// Creates the cubit.
  BranchDetailCubit({
    required this._getBranch,
    required this._watchBatches,
    required this._reconcileStudentCounters,
  }) : super(const BranchDetailLoading());

  final GetBranch _getBranch;
  final WatchBatches _watchBatches;
  final ReconcileStudentCounters _reconcileStudentCounters;
  StreamSubscription<List<Batch>>? _batchSubscription;
  Branch? _branch;
  String? _branchId;

  /// Loads the branch and listens to its batches.
  Future<void> started(String branchId) async {
    final sameBranch = _branchId == branchId;
    _branchId = branchId;
    final current = state;
    if (sameBranch && current is BranchDetailLoaded) {
      emit(current.copyWith(refreshing: true));
    } else {
      emit(const BranchDetailLoading());
    }
    final result = await _getBranch(branchId);
    switch (result) {
      case Success(:final value):
        _branch = value;
        unawaited(_reconcileStudentCounters(branchId));
        await _batchSubscription?.cancel();
        _batchSubscription = _watchBatches(branchId).listen(
          (batches) {
            final branch = _branch;
            if (branch != null) {
              emit(
                BranchDetailLoaded(
                  branch: branch,
                  batches: batches,
                ),
              );
            }
          },
        );
        emit(BranchDetailLoaded(branch: value, batches: const <Batch>[]));
      case Err(:final failure):
        emit(BranchDetailFailure(failure.message));
    }
  }

  @override
  Future<void> close() {
    unawaited(_batchSubscription?.cancel());
    return super.close();
  }
}

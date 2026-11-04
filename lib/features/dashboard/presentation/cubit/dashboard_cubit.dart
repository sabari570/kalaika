import 'dart:async';

import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/session/fee_month_session.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/core/utils/month_key_utils.dart';
import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/dashboard/domain/entities/monthly_summary.dart';
import 'package:feemanager/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:feemanager/features/dashboard/domain/usecases/dashboard_usecases.dart';
import 'package:feemanager/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Home dashboard with month-wise rollups.
class DashboardCubit extends Cubit<DashboardState> {
  /// Creates the cubit.
  DashboardCubit({
    required this.repository,
    required this.watchDashboardUser,
  }) : super(const DashboardLoading());

  final DashboardRepository repository;
  final WatchDashboardUser watchDashboardUser;

  StreamSubscription<Result<AppUser>>? _userSubscription;
  StreamSubscription<MonthlySummary>? _summarySubscription;
  StreamSubscription<List<Branch>>? _branchesSubscription;
  StreamSubscription<List<Batch>>? _batchesSubscription;

  AppUser? _user;
  MonthlySummary? _summary;
  List<Branch> _branches = <Branch>[];
  List<Batch> _batches = <Batch>[];
  DateTime _selectedMonth = FeeMonthSession.current();
  var _summaryGeneration = 0;

  /// Attaches dashboard listeners.
  void started() {
    unawaited(_userSubscription?.cancel());
    unawaited(_summarySubscription?.cancel());
    unawaited(_branchesSubscription?.cancel());
    unawaited(_batchesSubscription?.cancel());
    _selectedMonth = FeeMonthSession.current();
    _summary = null;
    _branches = <Branch>[];
    _batches = <Batch>[];
    emit(const DashboardLoading());

    _userSubscription = watchDashboardUser(const NoParams()).listen(
      (result) {
        switch (result) {
          case Success(:final value):
            _user = value;
            _emitIfReady();
          case Err():
            emit(const DashboardFailure(AppStrings.dashboardLoadFailed));
        }
      },
      onError: (_) {
        emit(const DashboardFailure(AppStrings.dashboardLoadFailed));
      },
    );

    _branchesSubscription = repository.watchBranches().listen(
      (branches) {
        _branches = branches;
        _emitIfReady();
      },
      onError: (_) {
        emit(const DashboardFailure(AppStrings.dashboardLoadFailed));
      },
    );

    _batchesSubscription = repository.watchActiveBatches().listen(
      (batches) {
        _batches = batches;
        _emitIfReady();
      },
      onError: (_) {
        emit(const DashboardFailure(AppStrings.dashboardLoadFailed));
      },
    );

    _listenSummary();
  }

  /// Updates the month and swaps only the summary listener.
  void monthChanged(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    FeeMonthSession.save(_selectedMonth);
    _summary = null;
    _summaryGeneration++;
    _listenSummary(_summaryGeneration);
  }

  void _listenSummary([int? generation]) {
    final listenGeneration = generation ?? _summaryGeneration;
    final monthKey = MonthKeyUtils.toMonthKey(_selectedMonth);
    unawaited(_summarySubscription?.cancel());
    _summarySubscription = repository.watchMonthlySummary(monthKey).listen(
      (summary) {
        if (listenGeneration != _summaryGeneration) {
          return;
        }
        _summary = summary;
        _emitIfReady();
      },
      onError: (_) {
        emit(const DashboardFailure(AppStrings.dashboardLoadFailed));
      },
    );
  }

  void _emitIfReady() {
    final user = _user;
    final summary = _summary;
    if (user == null || summary == null) {
      return;
    }
    final snapshot = DashboardSnapshotBuilder.build(
      monthKey: summary.monthKey,
      summary: summary,
      branches: _branches,
      batches: _batches,
    );
    emit(
      DashboardLoaded(
        user: user,
        selectedMonth: _selectedMonth,
        snapshot: snapshot,
      ),
    );
  }

  @override
  Future<void> close() {
    unawaited(_userSubscription?.cancel());
    unawaited(_summarySubscription?.cancel());
    unawaited(_branchesSubscription?.cancel());
    unawaited(_batchesSubscription?.cancel());
    return super.close();
  }
}

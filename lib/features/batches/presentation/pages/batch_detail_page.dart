import 'dart:async';

import 'package:feemanager/core/constants/app_routes.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/batches/domain/usecases/get_batch.dart';
import 'package:feemanager/features/batches/presentation/pages/batch_fees_tab.dart';
import 'package:feemanager/features/fees/presentation/cubit/fee_tracker_cubit.dart';
import 'package:feemanager/features/fees/presentation/pages/fee_tracker_tab.dart';
import 'package:feemanager/features/students/presentation/cubit/student_list_cubit.dart';
import 'package:feemanager/features/students/presentation/pages/batch_students_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Batch detail with Fees and Students tabs.
class BatchDetailPage extends StatefulWidget {
  /// Creates the batch detail screen.
  const BatchDetailPage({
    required this.branchId,
    required this.batchId,
    super.key,
  });

  /// Branch id from the route.
  final String branchId;

  /// Batch id from the route.
  final String batchId;

  @override
  State<BatchDetailPage> createState() => _BatchDetailPageState();
}

class _BatchDetailPageState extends State<BatchDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final Future<Result<Batch>> _batchFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _batchFuture = sl<GetBatch>()(
      GetBatchParams(
        branchId: widget.branchId,
        batchId: widget.batchId,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BatchDetailScope(
      branchId: widget.branchId,
      batchId: widget.batchId,
      child: FutureBuilder<Result<Batch>>(
        future: _batchFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return switch (snapshot.data!) {
            Success(:final value) => _BatchDetailScaffold(
              batch: value,
              branchId: widget.branchId,
              batchId: widget.batchId,
              tabController: _tabController,
            ),
            Err(:final failure) => Scaffold(
              appBar: AppBar(),
              body: Center(child: Text(failure.message)),
            ),
          };
        },
      ),
    );
  }
}

/// Provides batch-scoped cubits for the fees and students tabs.
class _BatchDetailScope extends StatefulWidget {
  const _BatchDetailScope({
    required this.branchId,
    required this.batchId,
    required this.child,
  });

  final String branchId;
  final String batchId;
  final Widget child;

  @override
  State<_BatchDetailScope> createState() => _BatchDetailScopeState();
}

class _BatchDetailScopeState extends State<_BatchDetailScope> {
  late final FeeTrackerCubit _feeTrackerCubit;
  late final StudentListCubit _studentListCubit;

  @override
  void initState() {
    super.initState();
    _feeTrackerCubit = sl<FeeTrackerCubit>();
    _studentListCubit = sl<StudentListCubit>();
  }

  @override
  void dispose() {
    unawaited(_feeTrackerCubit.close());
    unawaited(_studentListCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<FeeTrackerCubit>.value(value: _feeTrackerCubit),
        BlocProvider<StudentListCubit>.value(value: _studentListCubit),
      ],
      child: widget.child,
    );
  }
}

class _BatchDetailScaffold extends StatefulWidget {
  const _BatchDetailScaffold({
    required this.batch,
    required this.branchId,
    required this.batchId,
    required this.tabController,
  });

  final Batch batch;
  final String branchId;
  final String batchId;
  final TabController tabController;

  @override
  State<_BatchDetailScaffold> createState() => _BatchDetailScaffoldState();
}

class _BatchDetailScaffoldState extends State<_BatchDetailScaffold> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncListenersForTab(widget.tabController.index);
    });
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (widget.tabController.indexIsChanging) {
      return;
    }
    _syncListenersForTab(widget.tabController.index);
  }

  void _syncListenersForTab(int index) {
    final branchId = widget.branchId;
    final batchId = widget.batchId;
    if (index == 0) {
      context.read<StudentListCubit>().stopListening();
      context.read<FeeTrackerCubit>().started(
        branchId: branchId,
        batchId: batchId,
      );
      return;
    }
    context.read<FeeTrackerCubit>().detachListeners();
    context.read<StudentListCubit>().started(branchId, batchId);
  }

  @override
  Widget build(BuildContext context) {
    final batch = widget.batch;
    final branchId = widget.branchId;
    final batchId = widget.batchId;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(batch.name),
        bottom: TabBar(
          controller: widget.tabController,
          tabs: const <Widget>[
            Tab(text: AppStrings.tabFees),
            Tab(text: AppStrings.tabStudents),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: AppStrings.editBatch,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(
              AppRoutes.batchEditPath(branchId, batchId),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'add':
                  unawaited(
                    context.push(
                      AppRoutes.studentNewPath(branchId, batchId),
                    ),
                  );
                case 'import':
                  unawaited(
                    context.push(
                      AppRoutes.importStudentsPath(branchId, batchId),
                      extra: batch.defaultFee,
                    ),
                  );
              }
            },
            itemBuilder: (context) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'add',
                child: Text(AppStrings.addStudent),
              ),
              PopupMenuItem<String>(
                value: 'import',
                child: Text(AppStrings.importFromExcel),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          BatchDetailHeader(
            branchName: batch.branchName,
            danceStyle: batch.danceStyle,
            mode: batch.mode,
          ),
          Expanded(
            child: TabBarView(
              controller: widget.tabController,
              children: <Widget>[
                FeeTrackerTab(
                  branchId: branchId,
                  batchId: batchId,
                  batchDefaultFee: batch.defaultFee,
                ),
                BatchStudentsTab(branchId: branchId, batchId: batchId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

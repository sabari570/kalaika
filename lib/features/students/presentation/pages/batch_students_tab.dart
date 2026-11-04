import 'dart:async';

import 'package:feemanager/core/constants/app_routes.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/utils/phone_utils.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/empty_state.dart';
import 'package:feemanager/core/widgets/kalaika_async_body.dart';
import 'package:feemanager/core/widgets/kalaika_card.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:feemanager/features/students/presentation/cubit/student_list_cubit.dart';
import 'package:feemanager/features/students/presentation/cubit/student_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Student list tab on batch detail.
class BatchStudentsTab extends StatelessWidget {
  /// Creates the students tab.
  const BatchStudentsTab({
    required this.branchId,
    required this.batchId,
    super.key,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentListCubit, StudentListState>(
      builder: (context, state) {
        return switch (state) {
          StudentListLoading() => const KalaikaAsyncBody(
            phase: KalaikaAsyncPhase.loading,
            loadingPlaceholder: Center(
              child: KalaikaProgressIndicator(
                size: KalaikaProgressSize.large,
              ),
            ),
            child: SizedBox.shrink(),
          ),
          StudentListFailure(:final message) => EmptyState(
            message: message,
            actionLabel: AppStrings.retry,
            onAction: () => context.read<StudentListCubit>().started(
              branchId,
              batchId,
            ),
          ),
          StudentListLoaded(:final students, :final refreshing) =>
            KalaikaAsyncBody(
              phase: refreshing
                  ? KalaikaAsyncPhase.refreshing
                  : KalaikaAsyncPhase.ready,
              child: students.isEmpty
                ? EmptyState(
                    message: AppStrings.noStudentsYet,
                    actionLabel: AppStrings.addStudent,
                    onAction: () => context.push(
                      AppRoutes.studentNewPath(branchId, batchId),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      AppSpacing.sm,
                      AppSpacing.screenHorizontal,
                      AppSpacing.xxl * 4,
                    ),
                    itemCount: students.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _StudentRow(
                        student: student,
                        branchId: branchId,
                        batchId: batchId,
                      );
                    },
                  ),
            ),
        };
      },
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.student,
    required this.branchId,
    required this.batchId,
  });

  final Student student;
  final String branchId;
  final String batchId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.appColors;
    final guardian = student.guardianName?.trim() ?? '';
    final subtitle = guardian.isEmpty
        ? PhoneUtils.formatForDisplay(student.whatsappNumber)
        : '$guardian · ${PhoneUtils.formatForDisplay(student.whatsappNumber)}';

    return KalaikaCard(
      onTap: () => context.push(
        AppRoutes.studentDetailPath(branchId, batchId, student.id),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  student.fullName,
                  style: theme.titleMedium?.copyWith(
                    color: student.isActive ? null : colors.creamMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: theme.bodyMedium?.copyWith(color: colors.creamMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: student.isActive,
            onChanged: (value) => unawaited(
              _toggleActive(context, value),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(BuildContext context, bool value) async {
    final result = await context.read<StudentListCubit>().setActive(
      branchId: branchId,
      batchId: batchId,
      studentId: student.id,
      isActive: value,
    );
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case Success<void>():
        break;
      case Err(:final failure):
        AppSnackBar.showError(context, failure.message);
    }
  }
}

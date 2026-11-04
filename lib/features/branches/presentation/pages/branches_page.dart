import 'dart:async';

import 'package:feemanager/core/constants/app_routes.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/confirm_dialog.dart';
import 'package:feemanager/core/widgets/empty_state.dart';
import 'package:feemanager/core/widgets/kalaika_card.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/branches/presentation/cubit/branch_list_cubit.dart';
import 'package:feemanager/features/branches/presentation/cubit/branch_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Branches tab with list, create, edit and delete actions.
class BranchesPage extends StatelessWidget {
  /// Creates the branches tab.
  const BranchesPage({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    Branch branch,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: AppStrings.delete,
      message: AppStrings.deleteBranchConfirm,
      confirmLabel: AppStrings.delete,
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final result =
        await context.read<BranchListCubit>().deleteBranch(branch.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.branchNew),
        label: const Text(AppStrings.newBranch),
        icon: const Icon(Icons.add),
      ),
      body: BlocBuilder<BranchListCubit, BranchListState>(
          builder: (context, state) {
            return switch (state) {
              BranchListLoading() => const Center(
                child: KalaikaProgressIndicator(
                  size: KalaikaProgressSize.large,
                ),
              ),
              BranchListFailure(:final message) => EmptyState(
                message: message,
                actionLabel: AppStrings.retry,
                onAction: context.read<BranchListCubit>().started,
              ),
              BranchListLoaded(:final branches) =>
                branches.isEmpty
                    ? EmptyState(
                        message: AppStrings.noBranchesYet,
                        actionLabel: AppStrings.createBranch,
                        onAction: () => context.push(AppRoutes.branchNew),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenHorizontal,
                          AppSpacing.lg,
                          AppSpacing.screenHorizontal,
                          AppSpacing.xxl * 4,
                        ),
                        itemCount: branches.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final branch = branches[index];
                          return _BranchCard(
                            branch: branch,
                            onTap: () => context.push(
                              AppRoutes.branchDetailPath(branch.id),
                            ),
                            onEdit: () => context.push(
                              AppRoutes.branchEditPath(branch.id),
                            ),
                            onDelete: () =>
                                unawaited(_confirmDelete(context, branch)),
                          );
                        },
                      ),
            };
          },
        ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Branch branch;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.appColors;
    final location = branch.location.trim();
    final subtitle = location.isEmpty
        ? '${branch.batchCount} ${AppStrings.batchesLabel.toLowerCase()} · '
            '${branch.studentCount} ${AppStrings.studentsLabel.toLowerCase()}'
        : '$location · ${branch.batchCount} '
            '${AppStrings.batchesLabel.toLowerCase()} · '
            '${branch.studentCount} ${AppStrings.studentsLabel.toLowerCase()}';

    return KalaikaCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(branch.name, style: theme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: theme.bodyMedium?.copyWith(color: colors.creamMuted),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit();
                case 'delete':
                  onDelete();
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text(AppStrings.edit),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text(AppStrings.delete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

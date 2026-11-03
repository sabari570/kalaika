import 'package:feemanager/core/constants/app_routes.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/utils/batch_schedule_formatter.dart';
import 'package:feemanager/core/widgets/empty_state.dart';
import 'package:feemanager/core/widgets/kalaika_card.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/batches/presentation/widgets/mode_chip.dart';
import 'package:feemanager/features/branches/presentation/cubit/branch_detail_cubit.dart';
import 'package:feemanager/features/branches/presentation/cubit/branch_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Branch header and batch list for one branch.
class BranchDetailPage extends StatelessWidget {
  /// Creates the branch detail screen.
  const BranchDetailPage({required this.branchId, super.key});

  /// Branch document id from the route.
  final String branchId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.batchNewPath(branchId)),
        label: const Text(AppStrings.newBatch),
        icon: const Icon(Icons.add),
      ),
      body: BlocBuilder<BranchDetailCubit, BranchDetailState>(
        builder: (context, state) {
          return switch (state) {
            BranchDetailLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            BranchDetailFailure(:final message) => EmptyState(
              message: message,
              actionLabel: AppStrings.retry,
              onAction: () =>
                  context.read<BranchDetailCubit>().started(branchId),
            ),
            BranchDetailLoaded(:final branch, :final batches) =>
              CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  pinned: true,
                  title: Text(branch.name),
                  actions: <Widget>[
                    IconButton(
                      tooltip: AppStrings.editBranch,
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () =>
                          context.push(AppRoutes.branchEditPath(branchId)),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      AppSpacing.sm,
                      AppSpacing.screenHorizontal,
                      AppSpacing.lg,
                    ),
                    child: Text(
                      branch.location.trim().isEmpty
                          ? AppStrings.batchesLabel
                          : branch.location,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.appColors.creamMuted,
                      ),
                    ),
                  ),
                ),
                if (batches.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      message: AppStrings.noBatchesYet,
                      actionLabel: AppStrings.newBatch,
                      onAction: () =>
                          context.push(AppRoutes.batchNewPath(branchId)),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      0,
                      AppSpacing.screenHorizontal,
                      AppSpacing.xxl * 4,
                    ),
                    sliver: SliverList.separated(
                      itemCount: batches.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final batch = batches[index];
                        return _BatchListCard(
                          batch: batch,
                          onTap: () => context.push(
                            AppRoutes.batchDetailPath(branchId, batch.id),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          };
        },
      ),
    );
  }
}

class _BatchListCard extends StatelessWidget {
  const _BatchListCard({required this.batch, required this.onTap});

  final Batch batch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.appColors;
    final schedule = BatchScheduleFormatter.format(
      days: batch.days,
      classTime: batch.classTime,
    );

    return KalaikaCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(batch.name, style: theme.titleMedium),
              ),
              ModeChip(mode: batch.mode),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            batch.danceStyle,
            style: theme.bodyMedium?.copyWith(color: colors.creamMuted),
          ),
          if (schedule.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              schedule,
              style: theme.bodyMedium?.copyWith(color: colors.creamMuted),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${batch.studentCount} ${AppStrings.studentsLabel.toLowerCase()}',
            style: theme.bodySmall,
          ),
        ],
      ),
    );
  }
}

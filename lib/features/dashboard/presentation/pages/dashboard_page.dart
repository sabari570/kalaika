import 'dart:async';

import 'package:feemanager/core/constants/app_routes.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/utils/month_key_utils.dart';
import 'package:feemanager/core/widgets/background_glow.dart';
import 'package:feemanager/core/widgets/empty_state.dart';
import 'package:feemanager/core/widgets/kalaika_animated_metric.dart';
import 'package:feemanager/core/widgets/kalaika_card.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
import 'package:feemanager/core/widgets/kalaika_screen_body.dart';
import 'package:feemanager/core/widgets/month_selector.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:feemanager/core/widgets/section_header.dart';
import 'package:feemanager/core/widgets/stat_tile.dart';
import 'package:feemanager/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:feemanager/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:feemanager/features/dashboard/presentation/widgets/dashboard_branch_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Home dashboard tab.
class DashboardPage extends StatelessWidget {
  /// Creates the dashboard page.
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return BackgroundGlow(
          child: switch (state) {
            DashboardLoading() => const KalaikaScreenBody(
              child: Center(
                child: KalaikaProgressIndicator(
                  size: KalaikaProgressSize.large,
                ),
              ),
            ),
            DashboardFailure(:final message) => KalaikaScreenBody(
              child: EmptyState(
                message: message,
                actionLabel: AppStrings.retry,
                onAction: context.read<DashboardCubit>().started,
              ),
            ),
            DashboardLoaded() => _DashboardBody(state: state),
          },
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.state});

  final DashboardLoaded state;

  @override
  Widget build(BuildContext context) {
    final snapshot = state.snapshot;
    final theme = Theme.of(context).textTheme;
    final colors = context.appColors;
    final welcome = AppStrings.dashboardWelcome.replaceFirst(
      '{name}',
      state.user.firstName,
    );
    final sentLabel = AppStrings.dashboardStatSentOverPaid
        .replaceFirst('{sent}', '${snapshot.summary.sentCount}')
        .replaceFirst('{paid}', '${snapshot.summary.paidCount}');
    final pendingReceiptText =
        AppStrings.dashboardReceiptsPendingCount.replaceFirst(
          '{count}',
          '${snapshot.pendingReceiptCount}',
        );
    final formatRs = NumberFormat.decimalPattern().format;

    return KalaikaScreenBody(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                AppSpacing.md,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      welcome,
                      style: theme.headlineSmall,
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: colors.surfaceHigh,
                    backgroundImage: state.user.photoUrl == null
                        ? null
                        : NetworkImage(state.user.photoUrl!),
                    child: state.user.photoUrl == null
                        ? Icon(Icons.person_outline, color: colors.copper)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: MonthSelector(
                initialMonth: state.selectedMonth,
                onChanged: context.read<DashboardCubit>().monthChanged,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
              AppSpacing.screenHorizontal,
              AppSpacing.sm,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.lg,
                crossAxisSpacing: AppSpacing.lg,
                childAspectRatio: 1.35,
              ),
              delegate: SliverChildListDelegate(
                <Widget>[
                  KalaikaAnimatedMetric(
                    value: snapshot.summary.collected.toDouble(),
                    builder: (context, value) {
                      return StatTile(
                        label: AppStrings.dashboardStatCollected,
                        value: 'Rs. ${formatRs(value.round())}',
                        icon: Icons.payments_outlined,
                      );
                    },
                  ),
                  KalaikaAnimatedMetric(
                    value: snapshot.pendingAmount.toDouble(),
                    builder: (context, value) {
                      return StatTile(
                        label: AppStrings.dashboardStatPending,
                        value: 'Rs. ${formatRs(value.round())}',
                        icon: Icons.schedule_outlined,
                      );
                    },
                  ),
                  StatTile(
                    label: AppStrings.dashboardStatReceiptsSent,
                    value: sentLabel,
                    icon: Icons.mark_email_read_outlined,
                  ),
                  KalaikaAnimatedMetric(
                    value: snapshot.activeStudents.toDouble(),
                    builder: (context, value) {
                      return StatTile(
                        label: AppStrings.dashboardStatActiveStudents,
                        value: '${value.round()}',
                        icon: Icons.groups_outlined,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.md,
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppStrings.dashboardCollectionProgress,
                    style: theme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  KalaikaAnimatedMetric(
                    value: snapshot.collectionProgress,
                    builder: (context, progress) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 8,
                          color: colors.copper,
                          backgroundColor: colors.surfaceHigh,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: KalaikaCard(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            AppStrings.dashboardReceiptsPendingTitle,
                            style: theme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            pendingReceiptText,
                            style: theme.bodyMedium?.copyWith(
                              color: colors.creamMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedCopperButton(
                      label: AppStrings.dashboardReviewPending,
                      onPressed: snapshot.pendingReceiptCount == 0
                          ? null
                          : () {
                              unawaited(
                                context.push(
                                  AppRoutes.dashboardPending,
                                  extra: MonthKeyUtils.toMonthKey(
                                    state.selectedMonth,
                                  ),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.xl,
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
              ),
              child: SectionHeader(
                title: AppStrings.dashboardBranchesSection,
              ),
            ),
          ),
          if (snapshot.branchSections.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xxl * 3,
                ),
                child: EmptyState(
                  message: AppStrings.dashboardNoBranches,
                  actionLabel: AppStrings.createBranch,
                  onAction: () => context.push(AppRoutes.branchNew),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                AppSpacing.xxl * 3,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final section = snapshot.branchSections[index];
                    return DashboardBranchCard(
                      section: section,
                      onBranchTap: () => context.push(
                        AppRoutes.branchDetailPath(section.branch.id),
                      ),
                      onBatchTap: (branchId, batchId) => context.push(
                        AppRoutes.batchDetailPath(branchId, batchId),
                      ),
                    );
                  },
                  childCount: snapshot.branchSections.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

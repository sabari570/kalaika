import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/widgets/kalaika_card.dart';
import 'package:feemanager/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Branch summary card with nested batch rows.
class DashboardBranchCard extends StatelessWidget {
  /// Creates a branch card.
  const DashboardBranchCard({
    required this.section,
    required this.onBranchTap,
    required this.onBatchTap,
    super.key,
  });

  /// Branch section data.
  final DashboardBranchSection section;

  /// Opens branch detail.
  final VoidCallback onBranchTap;

  /// Opens batch fee tracker with branch and batch ids.
  final void Function(String branchId, String batchId) onBatchTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.appColors;
    final progress = section.expected == 0
        ? 0.0
        : section.collected / section.expected;
    final collectedText =
        NumberFormat.decimalPattern().format(section.collected);
    final expectedText =
        NumberFormat.decimalPattern().format(section.expected);
    final batchLabel = AppStrings.dashboardBranchBatches.replaceFirst(
      '{count}',
      '${section.branch.batchCount}',
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: KalaikaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            InkWell(
              onTap: onBranchTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(section.branch.name, style: theme.titleMedium),
                  Text(
                    batchLabel,
                    style: theme.bodySmall?.copyWith(
                      color: colors.creamMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Rs. $collectedText of Rs. $expectedText',
                    style: theme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 4,
                      color: colors.copper,
                      backgroundColor: colors.surfaceHigh,
                    ),
                  ),
                ],
              ),
            ),
            if (section.batches.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              ...section.batches.map(
                (row) => _BatchRow(
                  row: row,
                  onTap: () => onBatchTap(
                    section.branch.id,
                    row.batch.id,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BatchRow extends StatelessWidget {
  const _BatchRow({
    required this.row,
    required this.onTap,
  });

  final DashboardBatchRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.appColors;
    final paidLabel = AppStrings.dashboardBatchPaidOfTotal
        .replaceFirst('{paid}', '${row.paidCount}')
        .replaceFirst('{total}', '${row.batch.studentCount}');
    final progress = row.batch.studentCount == 0
        ? 0.0
        : row.paidCount / row.batch.studentCount;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(row.batch.name, style: theme.titleSmall),
                  Text(
                    paidLabel,
                    style: theme.bodySmall?.copyWith(
                      color: colors.creamMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 56,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 4,
                color: colors.gold,
                backgroundColor: colors.surfaceHigh,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

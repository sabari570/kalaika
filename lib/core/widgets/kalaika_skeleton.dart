import 'package:feemanager/core/constants/app_radius.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Solid placeholder block for loading list rows.
class KalaikaSkeletonBox extends StatelessWidget {
  /// Creates a skeleton box.
  const KalaikaSkeletonBox({
    this.width,
    this.height = 16,
    this.borderRadius = AppRadius.input,
    super.key,
  });

  /// Optional width; expands when null inside flex.
  final double? width;

  /// Block height.
  final double height;

  /// Corner radius.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: ColoredBox(
          color: colors.creamMuted.withValues(alpha: 0.22),
        ),
      ),
    );
  }
}

/// Placeholder mimicking a fee or student list row.
class KalaikaListRowSkeleton extends StatelessWidget {
  /// Creates a row skeleton.
  const KalaikaListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          KalaikaSkeletonBox(width: 48, height: 48),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                KalaikaSkeletonBox(height: 18),
                SizedBox(height: AppSpacing.xs),
                KalaikaSkeletonBox(width: 160, height: 14),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          KalaikaSkeletonBox(width: 56, height: 18),
        ],
      ),
    );
  }
}

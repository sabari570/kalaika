import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/widgets/kalaika_skeleton.dart';
import 'package:flutter/material.dart';

/// Placeholder while batch metadata loads.
class BatchDetailSkeleton extends StatelessWidget {
  /// Creates the skeleton scaffold body.
  const BatchDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              KalaikaSkeletonBox(height: 24, width: 180),
              SizedBox(height: AppSpacing.sm),
              KalaikaSkeletonBox(width: 240),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: KalaikaSkeletonBox(height: 40),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.md,
            ),
            child: Column(
              children: <Widget>[
                KalaikaListRowSkeleton(),
                KalaikaListRowSkeleton(),
                KalaikaListRowSkeleton(),
                KalaikaListRowSkeleton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

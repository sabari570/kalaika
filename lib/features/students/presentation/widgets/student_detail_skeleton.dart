import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/widgets/kalaika_skeleton.dart';
import 'package:flutter/material.dart';

/// Placeholder layout for the student detail screen.
class StudentDetailSkeleton extends StatelessWidget {
  /// Creates the skeleton.
  const StudentDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.lg,
      ),
      children: const <Widget>[
        KalaikaSkeletonBox(height: 200),
        SizedBox(height: AppSpacing.xl),
        KalaikaSkeletonBox(width: 140, height: 20),
        SizedBox(height: AppSpacing.md),
        KalaikaListRowSkeleton(),
        KalaikaListRowSkeleton(),
        KalaikaListRowSkeleton(),
      ],
    );
  }
}

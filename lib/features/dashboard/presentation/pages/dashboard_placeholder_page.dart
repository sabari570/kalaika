import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/widgets/background_glow.dart';
import 'package:flutter/material.dart';

/// Dashboard tab placeholder until M8.
class DashboardPlaceholderPage extends StatelessWidget {
  /// Creates the dashboard placeholder.
  const DashboardPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundGlow(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Center(
            child: Text(
              AppStrings.dashboardPlaceholder,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }
}

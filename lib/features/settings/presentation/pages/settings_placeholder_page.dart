import 'package:feemanager/core/constants/app_routes.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Settings tab placeholder until M8.
class SettingsPlaceholderPage extends StatelessWidget {
  /// Creates the settings placeholder.
  const SettingsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.settingsPlaceholder,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (kDebugMode) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              OutlinedCopperButton(
                label: AppStrings.openStyleGuide,
                onPressed: () => context.push(AppRoutes.styleGuide),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

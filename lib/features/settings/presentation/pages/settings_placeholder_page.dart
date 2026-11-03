import 'dart:async';

import 'package:feemanager/core/constants/app_routes.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/confirm_dialog.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:feemanager/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Settings tab placeholder until M8 (includes sign out for M2).
class SettingsPlaceholderPage extends StatelessWidget {
  /// Creates the settings placeholder.
  const SettingsPlaceholderPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: AppStrings.signOutConfirmTitle,
      message: AppStrings.signOutConfirmMessage,
      confirmLabel: AppStrings.signOut,
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final result = await sl<SignOut>()(const NoParams());
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case Success<void>():
        context.go(AppRoutes.login);
      case Err(:final failure):
        AppSnackBar.showError(context, failure.message);
    }
  }

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
            const SizedBox(height: AppSpacing.xl),
            OutlinedCopperButton(
              label: AppStrings.signOut,
              onPressed: () => unawaited(_signOut(context)),
            ),
            if (kDebugMode) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
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

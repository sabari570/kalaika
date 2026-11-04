import 'dart:async';

import 'package:feemanager/core/constants/app_routes.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/constants/app_version.dart';
import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/confirm_dialog.dart';
import 'package:feemanager/core/widgets/empty_state.dart';
import 'package:feemanager/core/widgets/kalaika_card.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
import 'package:feemanager/core/widgets/kalaika_screen_body.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:feemanager/core/widgets/section_header.dart';
import 'package:feemanager/features/auth/domain/usecases/sign_out.dart';
import 'package:feemanager/features/settings/domain/entities/user_settings_view.dart';
import 'package:feemanager/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:feemanager/features/settings/presentation/cubit/settings_state.dart';
import 'package:feemanager/features/settings/presentation/widgets/settings_info_row.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Settings tab with account, institute summary, and sign out.
class SettingsPage extends StatelessWidget {
  /// Creates the settings screen.
  const SettingsPage({super.key});

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
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return switch (state) {
          SettingsLoading() => const KalaikaScreenBody(
            child: Center(
              child: KalaikaProgressIndicator(
                size: KalaikaProgressSize.large,
              ),
            ),
          ),
          SettingsFailure(:final message) => KalaikaScreenBody(
            child: EmptyState(
              message: message,
              actionLabel: AppStrings.retry,
              onAction: context.read<SettingsCubit>().started,
            ),
          ),
          SettingsLoaded(:final view) => _SettingsContent(
            view: view,
            onSignOut: () => unawaited(_signOut(context)),
          ),
        };
      },
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.view,
    required this.onSignOut,
  });

  final UserSettingsView view;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.appColors;
    final previewLines = view.templatePreviewLines;

    return KalaikaScreenBody(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
          AppSpacing.screenHorizontal,
          AppSpacing.xxl * 3,
        ),
        children: <Widget>[
          Text(
            AppStrings.settingsScreenTitle,
            style: theme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: AppStrings.settingsAccount),
          KalaikaCard(
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.surfaceHigh,
                  backgroundImage: view.user.photoUrl == null
                      ? null
                      : NetworkImage(view.user.photoUrl!),
                  child: view.user.photoUrl == null
                      ? Icon(Icons.person_outline, color: colors.copper)
                      : null,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        view.user.displayName,
                        style: theme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        view.user.email,
                        style: theme.bodyMedium?.copyWith(
                          color: colors.creamMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        AppStrings.settingsGoogleAccount,
                        style: theme.labelSmall?.copyWith(
                          color: colors.creamMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: AppStrings.settingsInstitute),
          KalaikaCard(
            child: Column(
              children: <Widget>[
                SettingsInfoRow(
                  icon: Icons.business_outlined,
                  label: AppStrings.settingsInstituteName,
                  value: view.institute.name,
                ),
                SettingsInfoRow(
                  icon: Icons.format_quote_outlined,
                  label: AppStrings.settingsInstituteTagline,
                  value: view.institute.tagline,
                ),
                SettingsInfoRow(
                  icon: Icons.phone_outlined,
                  label: AppStrings.settingsInstitutePhone,
                  value: view.institute.phone,
                ),
                SettingsInfoRow(
                  icon: Icons.draw_outlined,
                  label: AppStrings.settingsInstituteSignatory,
                  value: view.institute.signatory,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: AppStrings.settingsMessageTemplate),
          KalaikaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppStrings.settingsTemplatePreview,
                  style: theme.labelLarge?.copyWith(
                    color: colors.creamMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (previewLines.isEmpty)
                  Text(
                    '—',
                    style: theme.bodyMedium?.copyWith(
                      color: colors.creamMuted,
                    ),
                  )
                else
                  ...previewLines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(
                        line,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodyMedium?.copyWith(
                          color: colors.creamMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: AppStrings.settingsSignOutSection),
          OutlinedCopperButton(
            label: AppStrings.signOut,
            onPressed: onSignOut,
          ),
          if (kDebugMode) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            OutlinedCopperButton(
              label: AppStrings.openStyleGuide,
              onPressed: () => context.push(AppRoutes.styleGuide),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: Text(
              '${AppStrings.appVersionLabel} ${AppVersion.name}',
              style: theme.bodySmall?.copyWith(color: colors.creamMuted),
            ),
          ),
        ],
      ),
    );
  }
}

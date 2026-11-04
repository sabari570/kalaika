import 'dart:async';

import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/app_text_field.dart';
import 'package:feemanager/core/widgets/empty_state.dart';
import 'package:feemanager/core/widgets/gradient_button.dart';
import 'package:feemanager/core/widgets/kalaika_card.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
import 'package:feemanager/core/widgets/kalaika_screen_body.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:feemanager/features/settings/presentation/cubit/template_settings_form_cubit.dart';
import 'package:feemanager/features/settings/presentation/cubit/template_settings_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Edits the WhatsApp message template with live preview.
class TemplateSettingsPage extends StatefulWidget {
  /// Creates the template editor.
  const TemplateSettingsPage({super.key});

  @override
  State<TemplateSettingsPage> createState() => _TemplateSettingsPageState();
}

class _TemplateSettingsPageState extends State<TemplateSettingsPage> {
  late final TextEditingController _templateController;

  @override
  void initState() {
    super.initState();
    _templateController = TextEditingController();
  }

  @override
  void dispose() {
    _templateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsTemplateEditor),
      ),
      body: BlocConsumer<TemplateSettingsFormCubit, TemplateSettingsFormState>(
        listener: (context, state) {
          if (state is TemplateSettingsFormReady &&
              _templateController.text != state.template) {
            _templateController.text = state.template;
          }
        },
        builder: (context, state) {
          return switch (state) {
            TemplateSettingsFormLoading() => const KalaikaScreenBody(
              child: Center(child: KalaikaProgressIndicator()),
            ),
            TemplateSettingsFormFailure(:final message) => KalaikaScreenBody(
              child: EmptyState(
                message: message,
                actionLabel: AppStrings.retry,
                onAction: context.read<TemplateSettingsFormCubit>().started,
              ),
            ),
            TemplateSettingsFormReady() => _TemplateSettingsForm(
              controller: _templateController,
              previewText: state.previewText,
              isSaving: state.isSaving,
              onSave: () => unawaited(_save(context)),
              onReset: () => unawaited(_reset(context)),
            ),
          };
        },
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final error = await context.read<TemplateSettingsFormCubit>().save();
    if (!context.mounted) {
      return;
    }
    if (error == null) {
      AppSnackBar.showSuccess(context, AppStrings.settingsTemplateSaved);
      context.pop();
    } else {
      AppSnackBar.showError(context, error);
    }
  }

  Future<void> _reset(BuildContext context) async {
    final error =
        await context.read<TemplateSettingsFormCubit>().resetToDefault();
    if (!context.mounted) {
      return;
    }
    if (error != null) {
      AppSnackBar.showError(context, error);
    }
  }
}

class _TemplateSettingsForm extends StatelessWidget {
  const _TemplateSettingsForm({
    required this.controller,
    required this.previewText,
    required this.isSaving,
    required this.onSave,
    required this.onReset,
  });

  final TextEditingController controller;
  final String previewText;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.appColors;
    final cubit = context.read<TemplateSettingsFormCubit>();

    return KalaikaScreenBody(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
          AppSpacing.screenHorizontal,
          AppSpacing.xxl,
        ),
        children: <Widget>[
          Text(
            AppStrings.settingsTemplatePlaceholders,
            style: theme.bodySmall?.copyWith(color: colors.creamMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: controller,
            label: AppStrings.settingsTemplateEditor,
            maxLines: 12,
            onChanged: cubit.templateChanged,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            AppStrings.settingsTemplatePreview,
            style: theme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          KalaikaCard(
            child: Text(
              previewText,
              style: theme.bodyMedium?.copyWith(
                color: colors.creamMuted,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedCopperButton(
            label: AppStrings.settingsResetTemplate,
            onPressed: isSaving ? null : onReset,
          ),
          const SizedBox(height: AppSpacing.sm),
          GradientButton(
            label: AppStrings.save,
            isLoading: isSaving,
            onPressed: isSaving ? null : onSave,
          ),
        ],
      ),
    );
  }
}

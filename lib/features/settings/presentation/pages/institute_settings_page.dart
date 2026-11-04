import 'dart:async';

import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/app_text_field.dart';
import 'package:feemanager/core/widgets/empty_state.dart';
import 'package:feemanager/core/widgets/gradient_button.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
import 'package:feemanager/core/widgets/kalaika_screen_body.dart';
import 'package:feemanager/features/settings/presentation/cubit/institute_settings_form_cubit.dart';
import 'package:feemanager/features/settings/presentation/cubit/institute_settings_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Edits institute details used on receipts.
class InstituteSettingsPage extends StatefulWidget {
  /// Creates the institute editor.
  const InstituteSettingsPage({super.key});

  @override
  State<InstituteSettingsPage> createState() => _InstituteSettingsPageState();
}

class _InstituteSettingsPageState extends State<InstituteSettingsPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _taglineController;
  late final TextEditingController _phoneController;
  late final TextEditingController _signatoryController;
  late final TextEditingController _footerController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _taglineController = TextEditingController();
    _phoneController = TextEditingController();
    _signatoryController = TextEditingController();
    _footerController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _phoneController.dispose();
    _signatoryController.dispose();
    _footerController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsInstitute),
      ),
      body:
          BlocConsumer<InstituteSettingsFormCubit, InstituteSettingsFormState>(
        listener: (context, state) {
          if (state is InstituteSettingsFormReady) {
            _syncControllers(state);
          }
        },
        builder: (context, state) {
          return switch (state) {
            InstituteSettingsFormLoading() => const KalaikaScreenBody(
              child: Center(child: KalaikaProgressIndicator()),
            ),
            InstituteSettingsFormFailure(:final message) => KalaikaScreenBody(
              child: EmptyState(
                message: message,
                actionLabel: AppStrings.retry,
                onAction: context.read<InstituteSettingsFormCubit>().started,
              ),
            ),
            InstituteSettingsFormReady(:final isSaving, :final nameError) =>
              _InstituteSettingsForm(
                isSaving: isSaving,
                nameController: _nameController,
                taglineController: _taglineController,
                phoneController: _phoneController,
                signatoryController: _signatoryController,
                footerController: _footerController,
                addressController: _addressController,
                nameError: nameError,
                onSave: () => unawaited(_save(context)),
              ),
          };
        },
      ),
    );
  }

  void _syncControllers(InstituteSettingsFormReady state) {
    final institute = state.institute;
    if (_nameController.text != institute.name) {
      _nameController.text = institute.name;
    }
    if (_taglineController.text != institute.tagline) {
      _taglineController.text = institute.tagline;
    }
    if (_phoneController.text != institute.phone) {
      _phoneController.text = institute.phone;
    }
    if (_signatoryController.text != institute.signatory) {
      _signatoryController.text = institute.signatory;
    }
    if (_footerController.text != institute.footerNote) {
      _footerController.text = institute.footerNote;
    }
    final addressText = state.addressText;
    if (_addressController.text != addressText) {
      _addressController.text = addressText;
    }
  }

  Future<void> _save(BuildContext context) async {
    final error = await context.read<InstituteSettingsFormCubit>().save();
    if (!context.mounted) {
      return;
    }
    if (error == null) {
      AppSnackBar.showSuccess(context, AppStrings.settingsInstituteSaved);
      context.pop();
    } else {
      AppSnackBar.showError(context, error);
    }
  }
}

class _InstituteSettingsForm extends StatelessWidget {
  const _InstituteSettingsForm({
    required this.isSaving,
    required this.nameController,
    required this.taglineController,
    required this.phoneController,
    required this.signatoryController,
    required this.footerController,
    required this.addressController,
    required this.nameError,
    required this.onSave,
  });

  final bool isSaving;
  final TextEditingController nameController;
  final TextEditingController taglineController;
  final TextEditingController phoneController;
  final TextEditingController signatoryController;
  final TextEditingController footerController;
  final TextEditingController addressController;
  final String? nameError;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InstituteSettingsFormCubit>();

    return KalaikaScreenBody(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
          AppSpacing.screenHorizontal,
          AppSpacing.xxl,
        ),
        children: <Widget>[
          AppTextField(
            controller: nameController,
            label: AppStrings.settingsInstituteName,
            onChanged: cubit.nameChanged,
          ),
          if (nameError != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              nameError!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppPalette.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: taglineController,
            label: AppStrings.settingsInstituteTagline,
            onChanged: cubit.taglineChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: phoneController,
            label: AppStrings.settingsInstitutePhone,
            keyboardType: TextInputType.phone,
            onChanged: cubit.phoneChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: addressController,
            label: AppStrings.settingsInstituteAddress,
            maxLines: 3,
            onChanged: cubit.addressChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: footerController,
            label: AppStrings.settingsInstituteFooter,
            maxLines: 2,
            onChanged: cubit.footerChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: signatoryController,
            label: AppStrings.settingsInstituteSignatory,
            onChanged: cubit.signatoryChanged,
          ),
          const SizedBox(height: AppSpacing.xxl),
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

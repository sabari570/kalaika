import 'dart:async';

import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/app_text_field.dart';
import 'package:feemanager/core/widgets/gradient_button.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
import 'package:feemanager/core/widgets/kalaika_screen_body.dart';
import 'package:feemanager/core/widgets/loading_overlay.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:feemanager/features/branches/presentation/cubit/branch_form_cubit.dart';
import 'package:feemanager/features/branches/presentation/cubit/branch_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Create or edit branch form.
class BranchFormPage extends StatefulWidget {
  /// Creates the branch form.
  const BranchFormPage({required this.isEditing, super.key});

  /// Whether the form edits an existing branch.
  final bool isEditing;

  @override
  State<BranchFormPage> createState() => _BranchFormPageState();
}

class _BranchFormPageState extends State<BranchFormPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _contactController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _syncControllers(BranchFormReady state) {
    if (_nameController.text != state.draft.name) {
      _nameController.text = state.draft.name;
    }
    if (_locationController.text != state.draft.location) {
      _locationController.text = state.draft.location;
    }
    if (_contactController.text != state.draft.contactNumber) {
      _contactController.text = state.draft.contactNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.isEditing ? AppStrings.editBranch : AppStrings.newBranch;

    return BlocConsumer<BranchFormCubit, BranchFormState>(
      listener: (context, state) {
        if (state is BranchFormSuccess) {
          context.pop();
        }
        if (state is BranchFormFailure) {
          AppSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isSaving = state is BranchFormSaving;
        BranchFormReady? ready;
        if (state is BranchFormReady) {
          ready = state;
          _syncControllers(state);
        } else if (state is BranchFormSaving) {
          ready = BranchFormReady(
            draft: state.draft,
            isEditing: widget.isEditing,
          );
        } else if (state is BranchFormFailure) {
          ready = BranchFormReady(
            draft: state.draft,
            isEditing: widget.isEditing,
          );
        }

        return LoadingOverlay(
          isLoading: isSaving,
          child: Scaffold(
            appBar: AppBar(title: Text(title)),
            body: ready == null
                ? const Center(
                    child: KalaikaProgressIndicator(),
                  )
                : KalaikaScreenBody(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        AppSpacing.lg,
                        AppSpacing.screenHorizontal,
                        AppSpacing.lg +
                            MediaQuery.viewInsetsOf(context).bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          AppTextField(
                            controller: _nameController,
                            label: AppStrings.branchName,
                            onChanged:
                                context.read<BranchFormCubit>().nameChanged,
                          ),
                          if (ready.nameError != null) ...<Widget>[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              ready.nameError!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppPalette.error),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _locationController,
                            label: AppStrings.branchLocation,
                            onChanged:
                                context.read<BranchFormCubit>().locationChanged,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _contactController,
                            label: AppStrings.branchContact,
                            keyboardType: TextInputType.phone,
                            onChanged:
                                context.read<BranchFormCubit>().contactChanged,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          GradientButton(
                            label: AppStrings.save,
                            isLoading: isSaving,
                            onPressed: isSaving
                                ? null
                                : () {
                                    unawaited(
                                      context.read<BranchFormCubit>().save(),
                                    );
                                  },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedCopperButton(
                            label: AppStrings.cancel,
                            onPressed: isSaving ? null : () => context.pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

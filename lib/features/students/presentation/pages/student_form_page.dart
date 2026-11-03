import 'dart:async';

import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/utils/age_utils.dart';
import 'package:feemanager/core/utils/phone_utils.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/app_text_field.dart';
import 'package:feemanager/core/widgets/confirm_dialog.dart';
import 'package:feemanager/core/widgets/gradient_button.dart';
import 'package:feemanager/core/widgets/loading_overlay.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:feemanager/features/students/presentation/cubit/student_form_cubit.dart';
import 'package:feemanager/features/students/presentation/cubit/student_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Create or edit student form.
class StudentFormPage extends StatefulWidget {
  /// Creates the student form.
  const StudentFormPage({required this.isEditing, super.key});

  /// Whether the form edits an existing student.
  final bool isEditing;

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _ageController;
  late final TextEditingController _guardianController;
  late final TextEditingController _guardianPhoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _feeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _whatsappController = TextEditingController();
    _ageController = TextEditingController();
    _guardianController = TextEditingController();
    _guardianPhoneController = TextEditingController();
    _addressController = TextEditingController();
    _feeController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _ageController.dispose();
    _guardianController.dispose();
    _guardianPhoneController.dispose();
    _addressController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _pickDob(BuildContext context, DateTime? current) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - 10),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null && context.mounted) {
      context.read<StudentFormCubit>().dateOfBirthChanged(picked);
    }
  }

  Future<void> _onPhoneConfirm(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: AppStrings.phoneConfirmTitle,
      message: AppStrings.phoneConfirmMessage,
    );
    if (confirmed == true && context.mounted) {
      await context.read<StudentFormCubit>().save(
        confirmInternationalPhone: true,
      );
    } else if (context.mounted) {
      context.read<StudentFormCubit>().cancelPhoneConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.isEditing ? AppStrings.editStudent : AppStrings.newStudent;

    return BlocConsumer<StudentFormCubit, StudentFormState>(
      listener: (context, state) {
        if (state is StudentFormSuccess) {
          context.pop();
        }
        if (state is StudentFormFailure) {
          AppSnackBar.showError(context, state.message);
        }
        if (state is StudentFormPhoneConfirm) {
          unawaited(_onPhoneConfirm(context));
        }
      },
      builder: (context, state) {
        final isSaving = state is StudentFormSaving;
        StudentFormReady? ready;
        if (state is StudentFormReady) {
          ready = state;
        } else if (state is StudentFormSaving) {
          ready = StudentFormReady(
            draft: state.draft,
            isEditing: widget.isEditing,
            sameAsPhone: false,
          );
        } else if (state is StudentFormFailure) {
          ready = StudentFormReady(
            draft: state.draft,
            isEditing: widget.isEditing,
            sameAsPhone: false,
          );
        } else if (state is StudentFormPhoneConfirm) {
          ready = StudentFormReady(
            draft: state.draft,
            isEditing: state.isEditing,
            sameAsPhone: false,
          );
        }

        if (ready != null) {
          _syncControllers(ready);
        }

        return LoadingOverlay(
          isLoading: isSaving,
          child: Scaffold(
            appBar: AppBar(title: Text(title)),
            body: ready == null
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                        vertical: AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          AppTextField(
                            controller: _nameController,
                            label: AppStrings.studentName,
                            onChanged:
                                context
                                    .read<StudentFormCubit>()
                                    .fullNameChanged,
                          ),
                          if (ready.nameError != null) ...<Widget>[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              ready.nameError!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppPalette.error),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _phoneController,
                            label: AppStrings.phoneNumber,
                            keyboardType: TextInputType.phone,
                            onChanged:
                                context.read<StudentFormCubit>().phoneChanged,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _whatsappController,
                            label: AppStrings.whatsappNumber,
                            keyboardType: TextInputType.phone,
                            onChanged: context
                                .read<StudentFormCubit>()
                                .whatsappChanged,
                          ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: ready.sameAsPhone,
                            onChanged: (value) {
                              context
                                  .read<StudentFormCubit>()
                                  .sameAsPhoneChanged(
                                    enabled: value ?? false,
                                  );
                            },
                            title: const Text(AppStrings.sameAsPhone),
                          ),
                          if (ready.whatsappError != null) ...<Widget>[
                            Text(
                              ready.whatsappError!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppPalette.error),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          OutlinedButton(
                            onPressed: () => unawaited(
                              _pickDob(context, ready!.draft.dateOfBirth),
                            ),
                            child: Text(
                              ready.draft.dateOfBirth == null
                                  ? AppStrings.dateOfBirth
                                  : DateFormat.yMMMd().format(
                                      ready.draft.dateOfBirth!,
                                    ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _ageController,
                            label: AppStrings.age,
                            keyboardType: TextInputType.number,
                            onChanged: ready.draft.dateOfBirth == null
                                ? context.read<StudentFormCubit>().ageChanged
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _guardianController,
                            label: AppStrings.guardian,
                            onChanged:
                                context
                                    .read<StudentFormCubit>()
                                    .guardianChanged,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _guardianPhoneController,
                            label: AppStrings.guardianPhone,
                            keyboardType: TextInputType.phone,
                            onChanged: context
                                .read<StudentFormCubit>()
                                .guardianPhoneChanged,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _addressController,
                            label: AppStrings.address,
                            maxLines: 3,
                            onChanged:
                                context.read<StudentFormCubit>().addressChanged,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _feeController,
                            label: AppStrings.monthlyFee,
                            keyboardType: TextInputType.number,
                            onChanged:
                                context.read<StudentFormCubit>().feeChanged,
                          ),
                          if (ready.batchDefaultFee != null) ...<Widget>[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '${AppStrings.batchFeeLabel}: '
                              'Rs. ${ready.batchDefaultFee}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: context.appColors.creamMuted,
                                  ),
                            ),
                          ],
                          if (ready.feeError != null) ...<Widget>[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              ready.feeError!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppPalette.error),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xxl),
                          GradientButton(
                            label: AppStrings.save,
                            isLoading: isSaving,
                            onPressed: isSaving
                                ? null
                                : () {
                                    unawaited(
                                      context.read<StudentFormCubit>().save(),
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

  void _syncControllers(StudentFormReady ready) {
    final draft = ready.draft;
    if (_nameController.text != draft.fullName) {
      _nameController.text = draft.fullName;
    }
    final phoneDisplay = draft.phoneNumber == null
        ? ''
        : PhoneUtils.formatForDisplay(draft.phoneNumber!);
    if (_phoneController.text != phoneDisplay && !ready.sameAsPhone) {
      _phoneController.text = phoneDisplay;
    }
    final waDisplay = draft.whatsappNumber.isEmpty
        ? ''
        : PhoneUtils.formatForDisplay(draft.whatsappNumber);
    if (_whatsappController.text != waDisplay) {
      _whatsappController.text = waDisplay;
    }
    final ageText = draft.dateOfBirth != null
        ? '${AgeUtils.ageFromDateOfBirth(draft.dateOfBirth!)}'
        : (draft.age?.toString() ?? '');
    if (_ageController.text != ageText) {
      _ageController.text = ageText;
    }
    if (_guardianController.text != (draft.guardianName ?? '')) {
      _guardianController.text = draft.guardianName ?? '';
    }
    if (_guardianPhoneController.text != (draft.guardianPhone ?? '')) {
      _guardianPhoneController.text = draft.guardianPhone ?? '';
    }
    if (_addressController.text != (draft.address ?? '')) {
      _addressController.text = draft.address ?? '';
    }
    final feeText =
        draft.monthlyFee == 0 ? '' : '${draft.monthlyFee}';
    if (_feeController.text != feeText) {
      _feeController.text = feeText;
    }
  }
}

import 'dart:async';

import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/constants/batch_constants.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/utils/batch_schedule_formatter.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/app_text_field.dart';
import 'package:feemanager/core/widgets/confirm_dialog.dart';
import 'package:feemanager/core/widgets/gradient_button.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
import 'package:feemanager/core/widgets/kalaika_screen_body.dart';
import 'package:feemanager/core/widgets/loading_overlay.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:feemanager/features/batches/domain/entities/batch_draft.dart';
import 'package:feemanager/features/batches/presentation/cubit/batch_form_cubit.dart';
import 'package:feemanager/features/batches/presentation/cubit/batch_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Create or edit batch form.
class BatchFormPage extends StatefulWidget {
  /// Creates the batch form.
  const BatchFormPage({required this.isEditing, super.key});

  /// Whether the form edits an existing batch.
  final bool isEditing;

  @override
  State<BatchFormPage> createState() => _BatchFormPageState();
}

class _BatchFormPageState extends State<BatchFormPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _timeController;
  late final TextEditingController _feeController;
  late final TextEditingController _customStyleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _timeController = TextEditingController();
    _feeController = TextEditingController();
    _customStyleController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _feeController.dispose();
    _customStyleController.dispose();
    super.dispose();
  }

  bool _isCustomStyle(String style) {
    return !BatchConstants.presetDanceStyles.contains(style);
  }

  String _dropdownValue(BatchDraft draft) {
    return _isCustomStyle(draft.danceStyle)
        ? BatchConstants.danceStyleOther
        : draft.danceStyle;
  }

  void _syncControllers(BatchFormReady state) {
    final draft = state.draft;
    if (_nameController.text != draft.name) {
      _nameController.text = draft.name;
    }
    if (_timeController.text != draft.classTime) {
      _timeController.text = draft.classTime;
    }
    final feeText = draft.defaultFee == 0 ? '' : '${draft.defaultFee}';
    if (_feeController.text != feeText) {
      _feeController.text = feeText;
    }
    if (_isCustomStyle(draft.danceStyle)) {
      if (_customStyleController.text != draft.danceStyle) {
        _customStyleController.text = draft.danceStyle;
      }
    }
  }

  Future<void> _showFeeChangeDialog(
    BuildContext context,
    BatchFormFeeChangePrompt prompt,
  ) async {
    final scope = await showDialog<BatchFeeApplyScope>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.batchFeeChangeTitle),
          content: const Text(AppStrings.batchFeeChangeMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                BatchFeeApplyScope.newStudentsOnly,
              ),
              child: const Text(AppStrings.applyFeeNewStudentsOnly),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                BatchFeeApplyScope.allActiveStudents,
              ),
              child: const Text(AppStrings.applyFeeAllStudents),
            ),
            TextButton(
              onPressed: () {
                context.read<BatchFormCubit>().cancelFeeChangePrompt();
                Navigator.of(dialogContext).pop();
              },
              child: const Text(AppStrings.cancel),
            ),
          ],
        );
      },
    );
    if (scope == null || !context.mounted) {
      return;
    }
    await context.read<BatchFormCubit>().save(feeScope: scope);
  }

  Future<void> _onDeleteOrDeactivate(BuildContext context) async {
    final cubit = context.read<BatchFormCubit>();
    final state = cubit.state;
    if (state is! BatchFormReady || !state.isEditing) {
      return;
    }
    final students = state.existingBatch?.studentCount ?? 0;
    if (students > 0) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: AppStrings.deactivateBatch,
        message: AppStrings.deactivateBatchConfirm,
        confirmLabel: AppStrings.deactivateBatch,
      );
      if (confirmed == true && context.mounted) {
        await cubit.deactivateCurrentBatch();
      }
      return;
    }
    final confirmed = await ConfirmDialog.show(
      context,
      title: AppStrings.delete,
      message: AppStrings.deleteBatchConfirm,
      confirmLabel: AppStrings.delete,
    );
    if (confirmed == true && context.mounted) {
      await cubit.deleteEmptyBatch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? AppStrings.editBatch : AppStrings.newBatch;

    return BlocConsumer<BatchFormCubit, BatchFormState>(
      listener: (context, state) {
        if (state is BatchFormSuccess) {
          context.pop();
        }
        if (state is BatchFormRemoved) {
          context.pop();
        }
        if (state is BatchFormFailure) {
          AppSnackBar.showError(context, state.message);
        }
        if (state is BatchFormFeeChangePrompt) {
          unawaited(_showFeeChangeDialog(context, state));
        }
      },
      builder: (context, state) {
        final isSaving = state is BatchFormSaving;
        BatchFormReady? ready;
        if (state is BatchFormReady) {
          ready = state;
          _syncControllers(state);
        } else if (state is BatchFormSaving) {
          ready = BatchFormReady(
            draft: state.draft,
            isEditing: widget.isEditing,
          );
        } else if (state is BatchFormFailure) {
          ready = BatchFormReady(
            draft: state.draft,
            isEditing: widget.isEditing,
          );
        } else if (state is BatchFormFeeChangePrompt) {
          ready = BatchFormReady(
            draft: state.draft,
            isEditing: true,
            existingBatch: state.existingBatch,
          );
          _syncControllers(ready);
        }

        return LoadingOverlay(
          isLoading: isSaving,
          child: Scaffold(
            appBar: AppBar(
              title: Text(title),
              actions: <Widget>[
                if (widget.isEditing && ready?.isEditing == true)
                  IconButton(
                    tooltip: AppStrings.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: isSaving
                        ? null
                        : () => unawaited(_onDeleteOrDeactivate(context)),
                  ),
              ],
            ),
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
                            label: AppStrings.batchName,
                            onChanged:
                                context.read<BatchFormCubit>().nameChanged,
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
                          DropdownButtonFormField<String>(
                            initialValue: _dropdownValue(ready.draft),
                            decoration: const InputDecoration(
                              labelText: AppStrings.danceStyle,
                            ),
                            items: <String>[
                              ...BatchConstants.presetDanceStyles,
                              BatchConstants.danceStyleOther,
                            ].map((style) {
                              return DropdownMenuItem<String>(
                                value: style,
                                child: Text(style),
                              );
                            }).toList(),
                            onChanged: isSaving
                                ? null
                                : (value) {
                                    if (value == null) {
                                      return;
                                    }
                                    if (value ==
                                        BatchConstants.danceStyleOther) {
                                      context
                                          .read<BatchFormCubit>()
                                          .danceStyleChanged(
                                            _customStyleController.text,
                                          );
                                    } else {
                                      context
                                          .read<BatchFormCubit>()
                                          .danceStyleChanged(value);
                                    }
                                  },
                          ),
                          if (_dropdownValue(ready.draft) ==
                              BatchConstants.danceStyleOther) ...<Widget>[
                            const SizedBox(height: AppSpacing.lg),
                            AppTextField(
                              controller: _customStyleController,
                              label: AppStrings.danceStyle,
                              onChanged: context
                                  .read<BatchFormCubit>()
                                  .danceStyleChanged,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            AppStrings.classMode,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SegmentedButton<String>(
                            segments: BatchConstants.modes
                                .map(
                                  (mode) => ButtonSegment<String>(
                                    value: mode,
                                    label: Text(
                                      BatchScheduleFormatter.modeLabel(mode),
                                    ),
                                  ),
                                )
                                .toList(),
                            selected: <String>{ready.draft.mode},
                            onSelectionChanged: isSaving
                                ? null
                                : (selection) {
                                    context.read<BatchFormCubit>().modeChanged(
                                      selection.first,
                                    );
                                  },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            AppStrings.classDays,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: BatchConstants.weekdayKeys.map((key) {
                              const labels = <String>[
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun',
                              ];
                              final index =
                                  BatchConstants.weekdayKeys.indexOf(key);
                              final selected = ready!.draft.days.contains(key);
                              return FilterChip(
                                label: Text(labels[index]),
                                selected: selected,
                                onSelected: isSaving
                                    ? null
                                    : (_) {
                                        context
                                            .read<BatchFormCubit>()
                                            .dayToggled(key);
                                      },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _timeController,
                            label: AppStrings.classTime,
                            onChanged:
                                context.read<BatchFormCubit>().classTimeChanged,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _feeController,
                            label: AppStrings.monthlyFee,
                            keyboardType: TextInputType.number,
                            onChanged:
                                context.read<BatchFormCubit>().feeChanged,
                          ),
                          if (ready.feeError != null) ...<Widget>[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              ready.feeError!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppPalette.error),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            AppStrings.batchFeeHelper,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: context.appColors.creamMuted),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          GradientButton(
                            label: AppStrings.save,
                            isLoading: isSaving,
                            onPressed: isSaving
                                ? null
                                : () {
                                    unawaited(
                                      context.read<BatchFormCubit>().save(),
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

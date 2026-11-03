import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/constants/batch_constants.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/batches/domain/entities/batch_draft.dart';
import 'package:feemanager/features/batches/domain/usecases/create_batch.dart';
import 'package:feemanager/features/batches/domain/usecases/deactivate_batch.dart';
import 'package:feemanager/features/batches/domain/usecases/delete_batch.dart';
import 'package:feemanager/features/batches/domain/usecases/get_batch.dart';
import 'package:feemanager/features/batches/domain/usecases/update_batch.dart';
import 'package:feemanager/features/batches/presentation/cubit/batch_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Create and edit batch form logic.
class BatchFormCubit extends Cubit<BatchFormState> {
  /// Creates the cubit.
  BatchFormCubit({
    required this._getBatch,
    required this._createBatch,
    required this._updateBatch,
    required this._deleteBatch,
    required this._deactivateBatch,
  }) : super(
         BatchFormReady(
           draft: _emptyDraft(),
           isEditing: false,
         ),
       );

  final GetBatch _getBatch;
  final CreateBatch _createBatch;
  final UpdateBatch _updateBatch;
  final DeleteBatch _deleteBatch;
  final DeactivateBatch _deactivateBatch;

  String? _branchId;
  String? _batchId;

  static BatchDraft _emptyDraft() {
    return BatchDraft(
      name: '',
      danceStyle: BatchConstants.presetDanceStyles.first,
      mode: BatchConstants.modeOffline,
      days: const <String>[],
      classTime: '',
      defaultFee: 0,
    );
  }

  /// Prepares a create form for [branchId].
  Future<void> initCreate(String branchId) async {
    _branchId = branchId;
    _batchId = null;
    emit(BatchFormReady(draft: _emptyDraft(), isEditing: false));
  }

  /// Loads batch data for editing.
  Future<void> initEdit(String branchId, String batchId) async {
    _branchId = branchId;
    _batchId = batchId;
    final result = await _getBatch(
      GetBatchParams(branchId: branchId, batchId: batchId),
    );
    switch (result) {
      case Success(:final value):
        emit(
          BatchFormReady(
            isEditing: true,
            existingBatch: value,
            draft: BatchDraft(
              name: value.name,
              danceStyle: value.danceStyle,
              mode: value.mode,
              days: value.days,
              classTime: value.classTime,
              defaultFee: value.defaultFee,
            ),
          ),
        );
      case Err(:final failure):
        emit(BatchFormFailure(failure.message, _emptyDraft()));
    }
  }

  void nameChanged(String value) => _mutateDraft(
    (draft) => BatchDraft(
      name: value,
      danceStyle: draft.danceStyle,
      mode: draft.mode,
      days: draft.days,
      classTime: draft.classTime,
      defaultFee: draft.defaultFee,
      feeApplyScope: draft.feeApplyScope,
    ),
    clearNameError: true,
  );

  void danceStyleChanged(String value) => _mutateDraft(
    (draft) => BatchDraft(
      name: draft.name,
      danceStyle: value,
      mode: draft.mode,
      days: draft.days,
      classTime: draft.classTime,
      defaultFee: draft.defaultFee,
      feeApplyScope: draft.feeApplyScope,
    ),
  );

  void modeChanged(String value) => _mutateDraft(
    (draft) => BatchDraft(
      name: draft.name,
      danceStyle: draft.danceStyle,
      mode: value,
      days: draft.days,
      classTime: draft.classTime,
      defaultFee: draft.defaultFee,
      feeApplyScope: draft.feeApplyScope,
    ),
  );

  void classTimeChanged(String value) => _mutateDraft(
    (draft) => BatchDraft(
      name: draft.name,
      danceStyle: draft.danceStyle,
      mode: draft.mode,
      days: draft.days,
      classTime: value,
      defaultFee: draft.defaultFee,
      feeApplyScope: draft.feeApplyScope,
    ),
  );

  void feeChanged(String value) {
    final fee = int.tryParse(value.trim()) ?? 0;
    _mutateDraft(
      (draft) => BatchDraft(
        name: draft.name,
        danceStyle: draft.danceStyle,
        mode: draft.mode,
        days: draft.days,
        classTime: draft.classTime,
        defaultFee: fee,
        feeApplyScope: draft.feeApplyScope,
      ),
      clearFeeError: true,
    );
  }

  void dayToggled(String day) {
    _mutateDraft((draft) {
      final days = List<String>.from(draft.days);
      if (days.contains(day)) {
        days.remove(day);
      } else {
        days.add(day);
      }
      return BatchDraft(
        name: draft.name,
        danceStyle: draft.danceStyle,
        mode: draft.mode,
        days: days,
        classTime: draft.classTime,
        defaultFee: draft.defaultFee,
        feeApplyScope: draft.feeApplyScope,
      );
    });
  }

  /// Returns to the editable form after a fee-change prompt.
  void cancelFeeChangePrompt() {
    final current = state;
    if (current is BatchFormFeeChangePrompt) {
      emit(
        BatchFormReady(
          draft: current.draft,
          isEditing: true,
          existingBatch: current.existingBatch,
        ),
      );
    }
  }

  /// Saves with optional fee propagation scope after a dialog.
  Future<void> save({BatchFeeApplyScope? feeScope}) async {
    final current = state;
    if (current is BatchFormFeeChangePrompt && feeScope != null) {
      await _persist(
        current.draft.copyWithFeeScope(feeScope),
        current.existingBatch,
      );
      return;
    }
    if (current is! BatchFormReady) {
      return;
    }
    final validation = _validate(current.draft);
    if (validation != null) {
      emit(
        current.copyWith(
          nameError: validation.$1,
          feeError: validation.$2,
        ),
      );
      return;
    }
    if (current.isEditing &&
        current.existingBatch != null &&
        current.draft.defaultFee != current.existingBatch!.defaultFee &&
        feeScope == null) {
      emit(
        BatchFormFeeChangePrompt(current.draft, current.existingBatch!),
      );
      return;
    }
    final draft = feeScope == null
        ? current.draft
        : current.draft.copyWithFeeScope(feeScope);
    await _persist(draft, current.existingBatch);
  }

  /// Deletes the batch when it has no students.
  Future<void> deleteEmptyBatch() async {
    final branchId = _branchId;
    final batchId = _batchId;
    if (branchId == null || batchId == null) {
      return;
    }
    final current = state;
    final existing = current is BatchFormReady ? current.existingBatch : null;
    if (existing != null && existing.studentCount > 0) {
      if (current is BatchFormReady) {
        emit(
          BatchFormFailure(
            AppStrings.cannotDeleteBatchWithStudents,
            current.draft,
          ),
        );
      }
      return;
    }
    final result = await _deleteBatch(
      DeleteBatchParams(branchId: branchId, batchId: batchId),
    );
    switch (result) {
      case Success():
        emit(const BatchFormRemoved());
      case Err(:final failure):
        if (current is BatchFormReady) {
          emit(BatchFormFailure(failure.message, current.draft));
        }
    }
  }

  /// Marks the batch inactive when it still has students.
  Future<void> deactivateCurrentBatch() async {
    final branchId = _branchId;
    final batchId = _batchId;
    if (branchId == null || batchId == null) {
      return;
    }
    final current = state;
    final result = await _deactivateBatch(
      DeleteBatchParams(branchId: branchId, batchId: batchId),
    );
    switch (result) {
      case Success():
        emit(const BatchFormRemoved());
      case Err(:final failure):
        if (current is BatchFormReady) {
          emit(BatchFormFailure(failure.message, current.draft));
        }
    }
  }

  Future<void> _persist(BatchDraft draft, Batch? existingBatch) async {
    final branchId = _branchId;
    if (branchId == null) {
      return;
    }
    emit(BatchFormSaving(draft));
    if (_batchId != null) {
      final result = await _updateBatch(
        UpdateBatchParams(
          branchId: branchId,
          batchId: _batchId!,
          draft: draft,
        ),
      );
      _handleSaveResult(result, draft);
    } else {
      final result = await _createBatch(
        CreateBatchParams(branchId: branchId, draft: draft),
      );
      _handleSaveResult(result, draft);
    }
  }

  void _handleSaveResult(Result<dynamic> result, BatchDraft draft) {
    switch (result) {
      case Success():
        emit(const BatchFormSuccess());
      case Err(:final failure):
        emit(BatchFormFailure(failure.message, draft));
    }
  }

  (String?, String?)? _validate(BatchDraft draft) {
    if (draft.name.trim().isEmpty) {
      return (AppStrings.batchNameRequired, null);
    }
    if (draft.defaultFee <= 0) {
      return (null, AppStrings.batchFeeInvalid);
    }
    return null;
  }

  void _mutateDraft(
    BatchDraft Function(BatchDraft draft) transform, {
    bool clearNameError = false,
    bool clearFeeError = false,
  }) {
    final current = state;
    if (current is BatchFormReady) {
      emit(
        current.copyWith(
          draft: transform(current.draft),
          nameError: clearNameError ? null : current.nameError,
          feeError: clearFeeError ? null : current.feeError,
        ),
      );
    }
  }
}

extension on BatchDraft {
  BatchDraft copyWithFeeScope(BatchFeeApplyScope scope) {
    return BatchDraft(
      name: name,
      danceStyle: danceStyle,
      mode: mode,
      days: days,
      classTime: classTime,
      defaultFee: defaultFee,
      feeApplyScope: scope,
    );
  }
}

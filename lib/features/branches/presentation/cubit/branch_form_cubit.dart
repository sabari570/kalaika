import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/branches/domain/entities/branch_draft.dart';
import 'package:feemanager/features/branches/domain/usecases/create_branch.dart';
import 'package:feemanager/features/branches/domain/usecases/get_branch.dart';
import 'package:feemanager/features/branches/domain/usecases/update_branch.dart';
import 'package:feemanager/features/branches/presentation/cubit/branch_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Create and edit branch form logic.
class BranchFormCubit extends Cubit<BranchFormState> {
  /// Creates the cubit.
  BranchFormCubit({
    required this._getBranch,
    required this._createBranch,
    required this._updateBranch,
  }) : super(
         const BranchFormReady(
           draft: BranchDraft(name: ''),
           isEditing: false,
         ),
       );

  final GetBranch _getBranch;
  final CreateBranch _createBranch;
  final UpdateBranch _updateBranch;
  String? _branchId;

  /// Prepares a new branch form.
  void initCreate() {
    _branchId = null;
    emit(
      const BranchFormReady(
        draft: BranchDraft(name: ''),
        isEditing: false,
      ),
    );
  }

  /// Loads an existing branch for editing.
  Future<void> initEdit(String branchId) async {
    _branchId = branchId;
    final result = await _getBranch(branchId);
    switch (result) {
      case Success(:final value):
        emit(
          BranchFormReady(
            isEditing: true,
            draft: BranchDraft(
              name: value.name,
              location: value.location,
              contactNumber: value.contactNumber,
            ),
          ),
        );
      case Err(:final failure):
        emit(
          BranchFormFailure(
            failure.message,
            const BranchDraft(name: ''),
          ),
        );
    }
  }

  /// Updates draft name.
  void nameChanged(String value) {
    final current = state;
    if (current is BranchFormReady) {
      emit(
        current.copyWith(
          draft: BranchDraft(
            name: value,
            location: current.draft.location,
            contactNumber: current.draft.contactNumber,
          ),
        ),
      );
    }
  }

  /// Updates draft location.
  void locationChanged(String value) {
    _updateDraft((draft) => BranchDraft(
      name: draft.name,
      location: value,
      contactNumber: draft.contactNumber,
    ));
  }

  /// Updates draft contact number.
  void contactChanged(String value) {
    _updateDraft((draft) => BranchDraft(
      name: draft.name,
      location: draft.location,
      contactNumber: value,
    ));
  }

  /// Validates and saves the branch.
  Future<void> save() async {
    final current = state;
    if (current is! BranchFormReady) {
      return;
    }
    if (current.draft.name.trim().isEmpty) {
      emit(current.copyWith(nameError: AppStrings.branchNameRequired));
      return;
    }
    emit(BranchFormSaving(current.draft));
    final Result<dynamic> result;
    if (current.isEditing && _branchId != null) {
      result = await _updateBranch(
        UpdateBranchParams(branchId: _branchId!, draft: current.draft),
      );
    } else {
      result = await _createBranch(current.draft);
    }
    switch (result) {
      case Success():
        emit(const BranchFormSuccess());
      case Err(:final failure):
        emit(BranchFormFailure(failure.message, current.draft));
    }
  }

  void _updateDraft(BranchDraft Function(BranchDraft draft) transform) {
    final current = state;
    if (current is BranchFormReady) {
      emit(current.copyWith(draft: transform(current.draft)));
    }
  }
}

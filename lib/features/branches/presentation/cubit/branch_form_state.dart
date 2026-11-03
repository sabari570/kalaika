import 'package:equatable/equatable.dart';
import 'package:feemanager/features/branches/domain/entities/branch_draft.dart';

/// Branch form states.
sealed class BranchFormState extends Equatable {
  const BranchFormState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Form ready for input.
final class BranchFormReady extends BranchFormState {
  const BranchFormReady({
    required this.draft,
    required this.isEditing,
    this.nameError,
  });

  final BranchDraft draft;
  final bool isEditing;
  final String? nameError;

  BranchFormReady copyWith({
    BranchDraft? draft,
    bool? isEditing,
    String? nameError,
  }) {
    return BranchFormReady(
      draft: draft ?? this.draft,
      isEditing: isEditing ?? this.isEditing,
      nameError: nameError,
    );
  }

  @override
  List<Object?> get props => <Object?>[draft, isEditing, nameError];
}

/// Save in progress.
final class BranchFormSaving extends BranchFormState {
  const BranchFormSaving(this.draft);

  final BranchDraft draft;

  @override
  List<Object?> get props => <Object?>[draft];
}

/// Save failed.
final class BranchFormFailure extends BranchFormState {
  const BranchFormFailure(this.message, this.draft);

  final String message;
  final BranchDraft draft;

  @override
  List<Object?> get props => <Object?>[message, draft];
}

/// Save succeeded.
final class BranchFormSuccess extends BranchFormState {
  const BranchFormSuccess();
}

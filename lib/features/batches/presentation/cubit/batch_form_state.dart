import 'package:equatable/equatable.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/batches/domain/entities/batch_draft.dart';

/// Batch form states.
sealed class BatchFormState extends Equatable {
  const BatchFormState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Form ready for editing.
final class BatchFormReady extends BatchFormState {
  const BatchFormReady({
    required this.draft,
    required this.isEditing,
    this.existingBatch,
    this.nameError,
    this.feeError,
  });

  final BatchDraft draft;
  final bool isEditing;
  final Batch? existingBatch;
  final String? nameError;
  final String? feeError;

  BatchFormReady copyWith({
    BatchDraft? draft,
    bool? isEditing,
    Batch? existingBatch,
    String? nameError,
    String? feeError,
  }) {
    return BatchFormReady(
      draft: draft ?? this.draft,
      isEditing: isEditing ?? this.isEditing,
      existingBatch: existingBatch ?? this.existingBatch,
      nameError: nameError,
      feeError: feeError,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[draft, isEditing, existingBatch, nameError, feeError];
}

/// Save in progress.
final class BatchFormSaving extends BatchFormState {
  const BatchFormSaving(this.draft);

  final BatchDraft draft;

  @override
  List<Object?> get props => <Object?>[draft];
}

/// Save failed.
final class BatchFormFailure extends BatchFormState {
  const BatchFormFailure(this.message, this.draft);

  final String message;
  final BatchDraft draft;

  @override
  List<Object?> get props => <Object?>[message, draft];
}

/// Save succeeded.
final class BatchFormSuccess extends BatchFormState {
  const BatchFormSuccess();
}

/// Batch removed or deactivated.
final class BatchFormRemoved extends BatchFormState {
  const BatchFormRemoved();
}

/// Fee change requires user choice before save.
final class BatchFormFeeChangePrompt extends BatchFormState {
  const BatchFormFeeChangePrompt(this.draft, this.existingBatch);

  final BatchDraft draft;
  final Batch existingBatch;

  @override
  List<Object?> get props => <Object?>[draft, existingBatch];
}

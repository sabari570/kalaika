import 'package:equatable/equatable.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:feemanager/features/students/domain/entities/student_draft.dart';

/// Student form states.
sealed class StudentFormState extends Equatable {
  const StudentFormState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Form ready for editing.
final class StudentFormReady extends StudentFormState {
  const StudentFormReady({
    required this.draft,
    required this.isEditing,
    required this.sameAsPhone,
    this.existingStudent,
    this.nameError,
    this.whatsappError,
    this.feeError,
    this.batchDefaultFee,
  });

  final StudentDraft draft;
  final bool isEditing;
  final bool sameAsPhone;
  final Student? existingStudent;
  final String? nameError;
  final String? whatsappError;
  final String? feeError;
  final int? batchDefaultFee;

  StudentFormReady copyWith({
    StudentDraft? draft,
    bool? isEditing,
    bool? sameAsPhone,
    Student? existingStudent,
    String? nameError,
    String? whatsappError,
    String? feeError,
    int? batchDefaultFee,
  }) {
    return StudentFormReady(
      draft: draft ?? this.draft,
      isEditing: isEditing ?? this.isEditing,
      sameAsPhone: sameAsPhone ?? this.sameAsPhone,
      existingStudent: existingStudent ?? this.existingStudent,
      nameError: nameError,
      whatsappError: whatsappError,
      feeError: feeError,
      batchDefaultFee: batchDefaultFee ?? this.batchDefaultFee,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    draft,
    isEditing,
    sameAsPhone,
    existingStudent,
    nameError,
    whatsappError,
    feeError,
    batchDefaultFee,
  ];
}

/// International phone confirmation required before save.
final class StudentFormPhoneConfirm extends StudentFormState {
  const StudentFormPhoneConfirm({
    required this.draft,
    required this.isEditing,
  });

  final StudentDraft draft;
  final bool isEditing;

  @override
  List<Object?> get props => <Object?>[draft, isEditing];
}

/// Save in progress.
final class StudentFormSaving extends StudentFormState {
  const StudentFormSaving(this.draft);

  final StudentDraft draft;

  @override
  List<Object?> get props => <Object?>[draft];
}

/// Save failed.
final class StudentFormFailure extends StudentFormState {
  const StudentFormFailure(this.message, this.draft);

  final String message;
  final StudentDraft draft;

  @override
  List<Object?> get props => <Object?>[message, draft];
}

/// Save succeeded.
final class StudentFormSuccess extends StudentFormState {
  const StudentFormSuccess();
}

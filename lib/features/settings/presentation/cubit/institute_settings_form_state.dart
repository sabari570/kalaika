import 'package:equatable/equatable.dart';
import 'package:feemanager/features/fees/domain/entities/institute_settings.dart';

/// Institute editor states.
sealed class InstituteSettingsFormState extends Equatable {
  const InstituteSettingsFormState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loading profile settings.
final class InstituteSettingsFormLoading extends InstituteSettingsFormState {
  /// Creates loading state.
  const InstituteSettingsFormLoading();
}

/// Editor ready for input.
final class InstituteSettingsFormReady extends InstituteSettingsFormState {
  /// Creates ready state.
  const InstituteSettingsFormReady({
    required this.institute,
    this.nameError,
    this.isSaving = false,
  });

  /// Current draft values.
  final InstituteSettings institute;

  /// Validation message for the name field.
  final String? nameError;

  /// True while persisting.
  final bool isSaving;

  /// Multiline address text for the form.
  String get addressText => institute.addressLines.join('\n');

  InstituteSettingsFormReady copyWith({
    InstituteSettings? institute,
    String? nameError,
    bool? isSaving,
    bool clearNameError = false,
  }) {
    return InstituteSettingsFormReady(
      institute: institute ?? this.institute,
      nameError: clearNameError ? null : nameError ?? this.nameError,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => <Object?>[institute, nameError, isSaving];
}

/// Failed to load settings.
final class InstituteSettingsFormFailure extends InstituteSettingsFormState {
  /// Creates failure state.
  const InstituteSettingsFormFailure(this.message);

  /// User-visible message.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

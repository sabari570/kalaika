import 'package:equatable/equatable.dart';
import 'package:feemanager/features/fees/domain/entities/institute_settings.dart';

/// Template editor states.
sealed class TemplateSettingsFormState extends Equatable {
  const TemplateSettingsFormState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loading profile settings.
final class TemplateSettingsFormLoading extends TemplateSettingsFormState {
  /// Creates loading state.
  const TemplateSettingsFormLoading();
}

/// Editor ready for input.
final class TemplateSettingsFormReady extends TemplateSettingsFormState {
  /// Creates ready state.
  const TemplateSettingsFormReady({
    required this.institute,
    required this.template,
    required this.previewText,
    this.isSaving = false,
  });

  /// Institute block for preview placeholders.
  final InstituteSettings institute;

  /// Template body.
  final String template;

  /// Rendered preview text.
  final String previewText;

  /// True while persisting.
  final bool isSaving;

  TemplateSettingsFormReady copyWith({
    InstituteSettings? institute,
    String? template,
    String? previewText,
    bool? isSaving,
  }) {
    return TemplateSettingsFormReady(
      institute: institute ?? this.institute,
      template: template ?? this.template,
      previewText: previewText ?? this.previewText,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    institute,
    template,
    previewText,
    isSaving,
  ];
}

/// Failed to load settings.
final class TemplateSettingsFormFailure extends TemplateSettingsFormState {
  /// Creates failure state.
  const TemplateSettingsFormFailure(this.message);

  /// User-visible message.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

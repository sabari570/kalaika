import 'dart:async';

import 'package:feemanager/core/constants/app_defaults.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/core/utils/template_utils.dart';
import 'package:feemanager/features/fees/domain/entities/institute_settings.dart';
import 'package:feemanager/features/settings/domain/entities/user_settings_view.dart';
import 'package:feemanager/features/settings/domain/usecases/update_settings.dart';
import 'package:feemanager/features/settings/domain/usecases/watch_user_settings.dart';
import 'package:feemanager/features/settings/presentation/cubit/template_settings_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Edits the WhatsApp message template.
class TemplateSettingsFormCubit extends Cubit<TemplateSettingsFormState> {
  /// Creates the cubit.
  TemplateSettingsFormCubit({
    required this.watchUserSettings,
    required this.updateMessageTemplate,
    required this.resetMessageTemplate,
  }) : super(const TemplateSettingsFormLoading());

  final WatchUserSettings watchUserSettings;
  final UpdateMessageTemplate updateMessageTemplate;
  final ResetMessageTemplate resetMessageTemplate;
  StreamSubscription<Result<UserSettingsView>>? _subscription;

  /// Loads the current template from Firestore.
  void started() {
    unawaited(_subscription?.cancel());
    emit(const TemplateSettingsFormLoading());
    _subscription = watchUserSettings(const NoParams()).listen(
      (result) {
        switch (result) {
          case Success(:final value):
            emit(
              TemplateSettingsFormReady(
                institute: value.institute,
                template: value.messageTemplate,
                previewText: _preview(value.messageTemplate, value.institute),
              ),
            );
          case Err():
            emit(
              const TemplateSettingsFormFailure(
                AppStrings.settingsLoadFailed,
              ),
            );
        }
      },
      onError: (_) {
        emit(
          const TemplateSettingsFormFailure(AppStrings.settingsLoadFailed),
        );
      },
    );
  }

  void templateChanged(String value) {
    final current = state;
    if (current is! TemplateSettingsFormReady || current.isSaving) {
      return;
    }
    emit(
      current.copyWith(
        template: value,
        previewText: _preview(value, current.institute),
      ),
    );
  }

  /// Persists the template; returns null on success or an error message.
  Future<String?> save() async {
    final current = state;
    if (current is! TemplateSettingsFormReady || current.isSaving) {
      return null;
    }
    emit(current.copyWith(isSaving: true));
    final result = await updateMessageTemplate(
      UpdateMessageTemplateParams(template: current.template),
    );
    switch (result) {
      case Success<void>():
        emit(current.copyWith(isSaving: false));
        return null;
      case Err(:final failure):
        emit(current.copyWith(isSaving: false));
        return failure.message;
    }
  }

  /// Resets the template to the default copy.
  Future<String?> resetToDefault() async {
    final current = state;
    if (current is! TemplateSettingsFormReady || current.isSaving) {
      return null;
    }
    emit(current.copyWith(isSaving: true));
    final result = await resetMessageTemplate(const NoParams());
    switch (result) {
      case Success<void>():
        emit(
          current.copyWith(
            template: AppDefaults.messageTemplate,
            previewText: _preview(
              AppDefaults.messageTemplate,
              current.institute,
            ),
            isSaving: false,
          ),
        );
        return null;
      case Err(:final failure):
        emit(current.copyWith(isSaving: false));
        return failure.message;
    }
  }

  String _preview(String template, InstituteSettings institute) {
    return TemplateUtils.apply(
      template,
      TemplateUtils.previewReplacements(institute: institute),
    );
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}

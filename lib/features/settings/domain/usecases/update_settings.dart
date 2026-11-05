import 'package:feemanager/core/constants/app_defaults.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/failure.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/fees/domain/entities/institute_settings.dart';
import 'package:feemanager/features/settings/domain/entities/whatsapp_delivery_mode.dart';
import 'package:feemanager/features/settings/domain/repositories/settings_repository.dart';

/// Persists institute details on the user profile.
class UpdateInstituteSettings
    implements UseCase<void, UpdateInstituteSettingsParams> {
  /// Creates the use case.
  UpdateInstituteSettings(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<void>> call(UpdateInstituteSettingsParams params) async {
    try {
      await _repository.updateInstitute(params.institute);
      return const Success<void>(null);
    } on FormatException catch (error) {
      return Err<void>(ValidationFailure(error.message));
    } on Object {
      return const Err<void>(UnknownFailure(AppStrings.settingsSaveFailed));
    }
  }
}

/// Parameters for [UpdateInstituteSettings].
class UpdateInstituteSettingsParams {
  /// Creates parameters.
  const UpdateInstituteSettingsParams({required this.institute});

  /// Institute values to save.
  final InstituteSettings institute;
}

/// Persists the WhatsApp message template.
class UpdateMessageTemplate
    implements UseCase<void, UpdateMessageTemplateParams> {
  /// Creates the use case.
  UpdateMessageTemplate(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<void>> call(UpdateMessageTemplateParams params) async {
    try {
      await _repository.updateMessageTemplate(params.template);
      return const Success<void>(null);
    } on Object {
      return const Err<void>(UnknownFailure(AppStrings.settingsSaveFailed));
    }
  }
}

/// Parameters for [UpdateMessageTemplate].
class UpdateMessageTemplateParams {
  /// Creates parameters.
  const UpdateMessageTemplateParams({required this.template});

  /// Template body.
  final String template;
}

/// Resets the message template to the default copy.
class ResetMessageTemplate implements UseCase<void, NoParams> {
  /// Creates the use case.
  ResetMessageTemplate(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) {
    return UpdateMessageTemplate(_repository)(
      const UpdateMessageTemplateParams(
        template: AppDefaults.messageTemplate,
      ),
    );
  }
}

/// Persists the WhatsApp delivery mode preference.
class UpdateWhatsAppDeliveryMode
    implements UseCase<void, UpdateWhatsAppDeliveryModeParams> {
  /// Creates the use case.
  UpdateWhatsAppDeliveryMode(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<void>> call(UpdateWhatsAppDeliveryModeParams params) async {
    try {
      await _repository.updateWhatsAppDeliveryMode(params.mode);
      return const Success<void>(null);
    } on Object {
      return const Err<void>(UnknownFailure(AppStrings.settingsSaveFailed));
    }
  }
}

/// Parameters for [UpdateWhatsAppDeliveryMode].
class UpdateWhatsAppDeliveryModeParams {
  /// Creates parameters.
  const UpdateWhatsAppDeliveryModeParams({required this.mode});

  /// Delivery mode to save.
  final WhatsAppDeliveryMode mode;
}

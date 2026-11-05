import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/settings/domain/entities/whatsapp_delivery_mode.dart';
import 'package:feemanager/features/settings/domain/repositories/settings_repository.dart';

/// Reads the teacher's WhatsApp delivery preference once.
class GetWhatsAppDeliveryMode
    implements UseCase<WhatsAppDeliveryMode, NoParams> {
  /// Creates the use case.
  GetWhatsAppDeliveryMode(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<WhatsAppDeliveryMode>> call(NoParams params) async {
    try {
      final mode = await _repository.getWhatsAppDeliveryMode();
      return Success<WhatsAppDeliveryMode>(mode);
    } on Object {
      return const Success<WhatsAppDeliveryMode>(
        WhatsAppDeliveryMode.defaultMode,
      );
    }
  }
}

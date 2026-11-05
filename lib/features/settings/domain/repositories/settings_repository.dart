import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/features/fees/domain/entities/institute_settings.dart';
import 'package:feemanager/features/settings/domain/entities/user_settings_view.dart';
import 'package:feemanager/features/settings/domain/entities/whatsapp_delivery_mode.dart';

/// Reads and updates user profile settings from Firestore.
abstract class SettingsRepository {
  /// Live settings for [user].
  Stream<UserSettingsView> watchForUser(AppUser user);

  /// One-shot WhatsApp delivery preference for the signed-in user.
  Future<WhatsAppDeliveryMode> getWhatsAppDeliveryMode();

  /// Persists institute details on the user profile.
  Future<void> updateInstitute(InstituteSettings institute);

  /// Persists the WhatsApp message template.
  Future<void> updateMessageTemplate(String template);

  /// Persists how fee confirmation is delivered on WhatsApp.
  Future<void> updateWhatsAppDeliveryMode(WhatsAppDeliveryMode mode);
}

import 'package:feemanager/core/constants/app_defaults.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/features/fees/domain/entities/institute_settings.dart';
import 'package:feemanager/features/settings/domain/entities/user_settings_view.dart';
import 'package:feemanager/features/settings/domain/entities/whatsapp_delivery_mode.dart';

/// Firestore read model for user settings.
abstract final class UserSettingsMapper {
  /// Builds [UserSettingsView] from a user document snapshot.
  static UserSettingsView fromUserDocument(
    AppUser user,
    Map<String, dynamic>? data,
  ) {
    final instituteRaw =
        data?[FirestoreKeys.institute] as Map<String, dynamic>?;
    final institute = _readInstitute(instituteRaw);
    final template = data?[FirestoreKeys.messageTemplate] as String? ??
        AppDefaults.messageTemplate;
    final deliveryMode = WhatsAppDeliveryModeCodec.parse(
      data?[FirestoreKeys.whatsappDeliveryMode] as String?,
    );
    return UserSettingsView(
      user: user,
      institute: institute,
      messageTemplate: template.trim(),
      whatsappDeliveryMode: deliveryMode,
    );
  }

  static InstituteSettings _readInstitute(Map<String, dynamic>? institute) {
    final map = institute ?? <String, dynamic>{};
    final addressRaw = map[FirestoreKeys.addressLines];
    final addressLines = addressRaw is List
        ? addressRaw.map((line) => line.toString()).toList()
        : <String>[];
    return InstituteSettings(
      name: map[FirestoreKeys.name] as String? ?? AppDefaults.instituteName,
      tagline:
          map[FirestoreKeys.tagline] as String? ?? AppDefaults.instituteTagline,
      addressLines: addressLines,
      phone: map[FirestoreKeys.phone] as String? ?? AppDefaults.institutePhone,
      footerNote: map[FirestoreKeys.footerNote] as String? ?? '',
      signatory: map[FirestoreKeys.signatory] as String? ?? '',
    );
  }
}

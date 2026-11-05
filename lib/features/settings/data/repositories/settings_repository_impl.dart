import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/features/fees/domain/entities/institute_settings.dart';
import 'package:feemanager/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:feemanager/features/settings/domain/entities/user_settings_view.dart';
import 'package:feemanager/features/settings/domain/entities/whatsapp_delivery_mode.dart';
import 'package:feemanager/features/settings/domain/repositories/settings_repository.dart';

/// Firestore implementation of [SettingsRepository].
class SettingsRepositoryImpl implements SettingsRepository {
  /// Creates the repository.
  SettingsRepositoryImpl({required this.remoteDataSource});

  /// Remote Firestore access.
  final SettingsRemoteDataSource remoteDataSource;

  @override
  Stream<UserSettingsView> watchForUser(AppUser user) {
    return remoteDataSource.watchForUser(user);
  }

  @override
  Future<WhatsAppDeliveryMode> getWhatsAppDeliveryMode() {
    return remoteDataSource.getWhatsAppDeliveryMode();
  }

  @override
  Future<void> updateInstitute(InstituteSettings institute) {
    return remoteDataSource.updateInstitute(institute);
  }

  @override
  Future<void> updateMessageTemplate(String template) {
    return remoteDataSource.updateMessageTemplate(template);
  }

  @override
  Future<void> updateWhatsAppDeliveryMode(WhatsAppDeliveryMode mode) {
    return remoteDataSource.updateWhatsAppDeliveryMode(mode);
  }
}

import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/features/settings/domain/entities/user_settings_view.dart';

/// Reads user profile settings from Firestore.
// ignore: one_member_abstracts
abstract class SettingsRepository {
  /// Live settings for [user].
  Stream<UserSettingsView> watchForUser(AppUser user);
}

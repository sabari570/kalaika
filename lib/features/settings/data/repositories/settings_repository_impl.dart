import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:feemanager/features/settings/domain/entities/user_settings_view.dart';
import 'package:feemanager/features/settings/domain/repositories/settings_repository.dart';

/// Firestore implementation of [SettingsRepository].
class SettingsRepositoryImpl implements SettingsRepository {
  /// Creates the repository.
  SettingsRepositoryImpl({required this._remoteDataSource});

  final SettingsRemoteDataSource _remoteDataSource;

  @override
  Stream<UserSettingsView> watchForUser(AppUser user) {
    return _remoteDataSource.watchForUser(user);
  }
}

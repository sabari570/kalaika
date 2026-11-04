import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/features/auth/domain/repositories/auth_repository.dart';
import 'package:feemanager/features/settings/domain/entities/user_settings_view.dart';
import 'package:feemanager/features/settings/domain/repositories/settings_repository.dart';

/// Streams settings for the signed-in user.
class WatchUserSettings implements StreamUseCase<UserSettingsView, NoParams> {
  /// Creates the use case.
  WatchUserSettings(this._authRepository, this._settingsRepository);

  final AuthRepository _authRepository;
  final SettingsRepository _settingsRepository;

  @override
  Stream<Result<UserSettingsView>> call(NoParams params) {
    return _authRepository
        .watchAuthUser()
        .where((user) => user != null)
        .cast<AppUser>()
        .asyncExpand(_settingsRepository.watchForUser)
        .map(Success<UserSettingsView>.new);
  }
}

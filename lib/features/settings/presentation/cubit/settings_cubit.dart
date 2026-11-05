import 'dart:async';

import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/settings/domain/entities/user_settings_view.dart';
import 'package:feemanager/features/settings/domain/entities/whatsapp_delivery_mode.dart';
import 'package:feemanager/features/settings/domain/usecases/update_settings.dart';
import 'package:feemanager/features/settings/domain/usecases/watch_user_settings.dart';
import 'package:feemanager/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Loads settings for the Settings tab and saves delivery mode.
class SettingsCubit extends Cubit<SettingsState> {
  /// Creates the cubit.
  SettingsCubit({
    required this._watchUserSettings,
    required this._updateWhatsAppDeliveryMode,
  }) : super(const SettingsLoading());

  final WatchUserSettings _watchUserSettings;
  final UpdateWhatsAppDeliveryMode _updateWhatsAppDeliveryMode;
  StreamSubscription<Result<UserSettingsView>>? _subscription;

  /// Starts listening to profile settings.
  void started() {
    unawaited(_subscription?.cancel());
    emit(const SettingsLoading());
    _subscription = _watchUserSettings(const NoParams()).listen(
      (result) {
        switch (result) {
          case Success(:final value):
            emit(SettingsLoaded(value));
          case Err():
            emit(const SettingsFailure(AppStrings.settingsLoadFailed));
        }
      },
      onError: (_) {
        emit(const SettingsFailure(AppStrings.settingsLoadFailed));
      },
    );
  }

  /// Persists [mode] when the teacher changes the delivery preference.
  Future<Result<void>> setWhatsAppDeliveryMode(
    WhatsAppDeliveryMode mode,
  ) {
    return _updateWhatsAppDeliveryMode(
      UpdateWhatsAppDeliveryModeParams(mode: mode),
    );
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}

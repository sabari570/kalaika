import 'dart:async';

import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/settings/domain/entities/user_settings_view.dart';
import 'package:feemanager/features/settings/domain/usecases/watch_user_settings.dart';
import 'package:feemanager/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Loads read-only settings for the Settings tab.
class SettingsCubit extends Cubit<SettingsState> {
  /// Creates the cubit.
  SettingsCubit({required this._watchUserSettings})
    : super(const SettingsLoading());

  final WatchUserSettings _watchUserSettings;
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

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}

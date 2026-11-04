import 'package:equatable/equatable.dart';
import 'package:feemanager/features/settings/domain/entities/user_settings_view.dart';

/// Settings tab states.
sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Initial load.
final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// Settings visible.
final class SettingsLoaded extends SettingsState {
  const SettingsLoaded(this.view);

  final UserSettingsView view;

  @override
  List<Object?> get props => <Object?>[view];
}

/// Load failed.
final class SettingsFailure extends SettingsState {
  const SettingsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

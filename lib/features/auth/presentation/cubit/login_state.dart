import 'package:equatable/equatable.dart';

/// Login screen states.
sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Idle login screen.
final class LoginInitial extends LoginState {
  /// Creates the initial login state.
  const LoginInitial();
}

/// Google sign-in in progress.
final class LoginLoading extends LoginState {
  /// Creates a loading login state.
  const LoginLoading();
}

/// Sign-in failed with a user-visible message.
final class LoginFailure extends LoginState {
  /// Creates a failure login state.
  const LoginFailure(this.message);

  /// Error message for snackbars.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

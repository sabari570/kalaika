import 'package:equatable/equatable.dart';

/// Splash screen states.
sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Splash is running initialization and animation timing.
final class SplashInitial extends SplashState {
  /// Creates the initial splash state.
  const SplashInitial();
}

/// Firebase or Google Sign-In initialization failed.
final class SplashInitFailed extends SplashState {
  /// Creates a failed splash state.
  const SplashInitFailed(this.message);

  /// User-visible error message.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Splash timing complete; navigation may proceed.
final class SplashReady extends SplashState {
  /// Creates a ready splash state.
  const SplashReady({required this.isAuthenticated});

  /// Whether a user session is active.
  final bool isAuthenticated;

  @override
  List<Object?> get props => <Object?>[isAuthenticated];
}

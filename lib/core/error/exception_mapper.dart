import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/failure.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Maps thrown exceptions to typed [Failure] instances at repository
/// boundaries.
abstract final class ExceptionMapper {
  /// Converts [error] and optional [stackTrace] into a [Failure].
  static Failure map(Object error, [StackTrace? stackTrace]) {
    if (error is FirebaseAuthException) {
      return AuthFailure(_authMessage(error));
    }
    if (error is FirebaseException) {
      return const UnknownFailure(AppStrings.firebaseInitFailed);
    }
    if (error is AuthFailure) {
      return error;
    }
    if (error is StateError) {
      final message = error.message;
      if (message.isEmpty) {
        return const ValidationFailure(AppStrings.unknownError);
      }
      return ValidationFailure(message);
    }
    return const UnknownFailure(AppStrings.unknownError);
  }

  static String _authMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'network-request-failed' => AppStrings.networkError,
      _ => AppStrings.signInFailed,
    };
  }
}

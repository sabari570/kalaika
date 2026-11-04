import 'package:cloud_functions/cloud_functions.dart';
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
    if (error is FirebaseFunctionsException) {
      return _functionsFailure(error);
    }
    if (error is FormatException) {
      return const ServerFailure(AppStrings.receiptGenerateFailed);
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

  static Failure _functionsFailure(FirebaseFunctionsException error) {
    return switch (error.code) {
      'unauthenticated' => const AuthFailure(AppStrings.signInFailed),
      'permission-denied' => const PermissionFailure(AppStrings.unknownError),
      'not-found' => const NotFoundFailure(AppStrings.unknownError),
      'invalid-argument' => ValidationFailure(
        error.message ?? AppStrings.unknownError,
      ),
      'failed-precondition' => ValidationFailure(
        error.message ?? AppStrings.unknownError,
      ),
      'unavailable' => const NetworkFailure(AppStrings.networkError),
      'internal' => const ServerFailure(AppStrings.receiptGenerateFailed),
      _ => const ServerFailure(AppStrings.receiptGenerateFailed),
    };
  }
}

/// Base type for domain and data layer failures.
sealed class Failure {
  /// Creates a failure with a user-presentable [message].
  const Failure(this.message);

  /// Formal wording suitable for snackbars and dialogs.
  final String message;
}

/// Network or connectivity related failure.
final class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure].
  const NetworkFailure([super.message = '']);
}

/// Authentication or session failure.
final class AuthFailure extends Failure {
  /// Creates an [AuthFailure].
  const AuthFailure([super.message = '']);
}

/// Firestore or storage permission denied.
final class PermissionFailure extends Failure {
  /// Creates a [PermissionFailure].
  const PermissionFailure([super.message = '']);
}

/// Requested document or entity not found.
final class NotFoundFailure extends Failure {
  /// Creates a [NotFoundFailure].
  const NotFoundFailure([super.message = '']);
}

/// Input or business rule validation failure.
final class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure].
  const ValidationFailure([super.message = '']);
}

/// Cloud Function or server-side failure.
final class ServerFailure extends Failure {
  /// Creates a [ServerFailure].
  const ServerFailure([super.message = '']);
}

/// Unclassified failure.
final class UnknownFailure extends Failure {
  /// Creates an [UnknownFailure].
  const UnknownFailure([super.message = '']);
}

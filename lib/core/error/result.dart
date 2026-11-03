import 'package:feemanager/core/error/failure.dart';

/// Discriminated result for repository operations.
sealed class Result<T> {
  const Result();
}

/// Successful result carrying [value].
final class Success<T> extends Result<T> {
  /// Creates a [Success].
  const Success(this.value);

  /// The successful value.
  final T value;
}

/// Failed result carrying [failure].
final class Err<T> extends Result<T> {
  /// Creates an [Err].
  const Err(this.failure);

  /// The failure that occurred.
  final Failure failure;
}

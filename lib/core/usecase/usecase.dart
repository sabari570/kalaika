import 'package:feemanager/core/error/result.dart';

// NOTE: Plan Section 2 requires UseCase base types for all features.
// ignore_for_file: one_member_abstracts

/// Marker for use cases that take no parameters.
final class NoParams {
  /// Creates [NoParams].
  const NoParams();
}

/// Base contract for a single-responsibility application action.
abstract class UseCase<T, Params> {
  /// Executes the use case with [params].
  Future<Result<T>> call(Params params);
}

/// Base contract for stream-based use cases.
abstract class StreamUseCase<T, Params> {
  /// Subscribes to a stream for [params].
  Stream<Result<T>> call(Params params);
}

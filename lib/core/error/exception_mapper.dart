import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/failure.dart';

/// Maps thrown exceptions to typed [Failure] instances at repository
/// boundaries.
abstract final class ExceptionMapper {
  /// Converts [error] and optional [stackTrace] into a [Failure].
  static Failure map(Object error, [StackTrace? stackTrace]) {
    // NOTE: Firebase-specific mapping is added when data sources exist (M2+).
    return const UnknownFailure(AppStrings.unknownError);
  }
}

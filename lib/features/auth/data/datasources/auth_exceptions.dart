/// Thrown when Google or Firebase sign-in fails in the data layer.
final class SignInFailedException implements Exception {
  /// Creates a sign-in failure exception.
  const SignInFailedException(this.message);

  /// Formal error message.
  final String message;

  @override
  String toString() => 'SignInFailedException: $message';
}

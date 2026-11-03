import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/features/auth/domain/repositories/auth_repository.dart';

/// Signs in with a Google account.
class SignInWithGoogle implements UseCase<AppUser, NoParams> {
  /// Creates [SignInWithGoogle].
  SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AppUser>> call(NoParams params) {
    return _repository.signInWithGoogle();
  }
}

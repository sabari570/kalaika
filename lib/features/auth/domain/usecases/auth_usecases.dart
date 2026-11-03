import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/features/auth/domain/repositories/auth_repository.dart';

/// Initializes Firebase and Google Sign-In.
class InitializeAuth implements UseCase<void, NoParams> {
  /// Creates [InitializeAuth].
  InitializeAuth(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.initialize();
  }
}

/// Observes authentication state changes.
class WatchAuthUser implements StreamUseCase<AppUser?, NoParams> {
  /// Creates [WatchAuthUser].
  WatchAuthUser(this._repository);

  final AuthRepository _repository;

  @override
  Stream<Result<AppUser?>> call(NoParams params) {
    return _repository.watchAuthUser().map(Success<AppUser?>.new);
  }
}

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

/// Signs out the current user.
class SignOut implements UseCase<void, NoParams> {
  /// Creates [SignOut].
  SignOut(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.signOut();
  }
}

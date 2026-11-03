import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/features/auth/domain/repositories/auth_repository.dart';

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

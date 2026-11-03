import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/auth/domain/repositories/auth_repository.dart';

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

import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/auth/domain/repositories/auth_repository.dart';

/// Completes Google Sign-In client setup at splash (Firebase starts in main).
class InitializeAuth implements UseCase<void, NoParams> {
  /// Creates [InitializeAuth].
  InitializeAuth(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.initialize();
  }
}

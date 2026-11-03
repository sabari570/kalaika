import 'dart:async';

import 'package:feemanager/core/constants/app_durations.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/auth/domain/repositories/auth_repository.dart';
import 'package:feemanager/features/auth/domain/usecases/initialize_auth.dart';
import 'package:feemanager/features/auth/presentation/cubit/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Coordinates Firebase initialization and splash timing.
class SplashCubit extends Cubit<SplashState> {
  /// Creates a splash cubit.
  SplashCubit({
    required this._initializeAuth,
    required this._authRepository,
  }) : super(const SplashInitial());

  final InitializeAuth _initializeAuth;
  final AuthRepository _authRepository;

  StreamSubscription<dynamic>? _authWaitSubscription;

  /// Starts initialization and waits for auth plus minimum splash time.
  Future<void> started() async {
    final initResult = await _initializeAuth(const NoParams());
    if (isClosed) {
      return;
    }
    switch (initResult) {
      case Success<void>():
        break;
      case Err<void>(:final failure):
        final message = failure.message.isEmpty
            ? AppStrings.firebaseInitFailed
            : failure.message;
        emit(SplashInitFailed(message));
        return;
    }

    final minimumDelay = Future<void>.delayed(AppDurations.splashMinimum);
    final authResolved = Completer<void>();
    _authWaitSubscription = _authRepository.watchAuthUser().listen((_) {
      if (!authResolved.isCompleted) {
        authResolved.complete();
      }
    });

    await Future.wait(<Future<void>>[minimumDelay, authResolved.future]);
    if (isClosed) {
      return;
    }
    emit(
      SplashReady(isAuthenticated: _authRepository.currentUser != null),
    );
  }

  @override
  Future<void> close() {
    unawaited(_authWaitSubscription?.cancel());
    return super.close();
  }
}

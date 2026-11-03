import 'package:feemanager/core/error/failure.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:feemanager/features/auth/presentation/cubit/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Handles Google sign-in on the login screen.
class LoginCubit extends Cubit<LoginState> {
  /// Creates a login cubit.
  LoginCubit({required this._signInWithGoogle})
    : super(const LoginInitial());

  final SignInWithGoogle _signInWithGoogle;

  /// Starts interactive Google sign-in.
  Future<void> signInWithGoogle() async {
    emit(const LoginLoading());
    final result = await _signInWithGoogle(const NoParams());
    if (isClosed) {
      return;
    }
    switch (result) {
      case Success():
        emit(const LoginInitial());
      case Err(:final failure):
        if (failure is AuthFailure && failure.message.isEmpty) {
          emit(const LoginInitial());
          return;
        }
        emit(LoginFailure(failure.message));
    }
  }
}

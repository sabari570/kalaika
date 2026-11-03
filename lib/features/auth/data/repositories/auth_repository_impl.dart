import 'dart:async';

import 'package:feemanager/core/error/exception_mapper.dart';
import 'package:feemanager/core/error/failure.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/auth/data/datasources/auth_exceptions.dart';
import 'package:feemanager/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/features/auth/domain/repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase-backed [AuthRepository] implementation.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates the repository and begins listening to auth state.
  AuthRepositoryImpl({required this._remoteDataSource}) {
    _authSubscription = _remoteDataSource.watchAuthUser().listen(
      (user) => _currentUser = user,
    );
  }

  final AuthRemoteDataSource _remoteDataSource;
  AppUser? _currentUser;
  late final StreamSubscription<AppUser?> _authSubscription;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> watchAuthUser() {
    return _remoteDataSource.watchAuthUser();
  }

  @override
  Future<Result<void>> initialize() async {
    try {
      await _remoteDataSource.initialize();
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return Err<void>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<AppUser>> signInWithGoogle() async {
    try {
      final user = await _remoteDataSource.signInWithGoogle();
      _currentUser = user;
      return Success<AppUser>(user);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return const Err<AppUser>(AuthFailure());
      }
      return Err<AppUser>(ExceptionMapper.map(error));
    } on SignInFailedException catch (error) {
      return Err<AppUser>(AuthFailure(error.message));
    } on Object catch (error, stackTrace) {
      return Err<AppUser>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      _currentUser = null;
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return Err<void>(ExceptionMapper.map(error, stackTrace));
    }
  }

  /// Releases the auth state subscription.
  Future<void> dispose() async {
    await _authSubscription.cancel();
  }
}

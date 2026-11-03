import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:feemanager/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:feemanager/features/auth/domain/repositories/auth_repository.dart';
import 'package:feemanager/features/auth/domain/usecases/initialize_auth.dart';
import 'package:feemanager/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:feemanager/features/auth/domain/usecases/sign_out.dart';
import 'package:feemanager/features/auth/domain/usecases/watch_auth_user.dart';
import 'package:feemanager/features/auth/presentation/cubit/login_cubit.dart';
import 'package:feemanager/features/auth/presentation/cubit/splash_cubit.dart';

/// Registers authentication feature dependencies.
void configureAuthDependencies() {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      AuthRemoteDataSource.new,
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
    )
    ..registerLazySingleton(
      () => InitializeAuth(sl<AuthRepository>()),
    )
    ..registerLazySingleton(
      () => WatchAuthUser(sl<AuthRepository>()),
    )
    ..registerLazySingleton(
      () => SignInWithGoogle(sl<AuthRepository>()),
    )
    ..registerLazySingleton(
      () => SignOut(sl<AuthRepository>()),
    )
    ..registerFactory(
      () => SplashCubit(
        initializeAuth: sl<InitializeAuth>(),
        authRepository: sl<AuthRepository>(),
      ),
    )
    ..registerFactory(
      () => LoginCubit(signInWithGoogle: sl<SignInWithGoogle>()),
    );
}

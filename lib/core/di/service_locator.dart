import 'package:feemanager/core/router/auth_refresh_listenable.dart';
import 'package:feemanager/features/auth/di/auth_di.dart';
import 'package:feemanager/features/auth/domain/repositories/auth_repository.dart';
import 'package:feemanager/features/branches/di/branches_di.dart';
import 'package:get_it/get_it.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Registers application dependencies (extended per feature in later
/// milestones).
void configureDependencies() {
  configureAuthDependencies();
  configureBranchesDependencies();
  sl.registerLazySingleton<AuthRefreshListenable>(
    () => AuthRefreshListenable(sl<AuthRepository>()),
  );
}

import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/features/auth/domain/repositories/auth_repository.dart';
import 'package:feemanager/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:feemanager/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:feemanager/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:feemanager/features/dashboard/domain/usecases/dashboard_usecases.dart';
import 'package:feemanager/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:feemanager/features/dashboard/presentation/cubit/pending_receipts_cubit.dart';

/// Registers dashboard feature dependencies.
void configureDashboardDependencies() {
  sl
    ..registerLazySingleton(DashboardRemoteDataSource.new)
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(
        remoteDataSource: sl<DashboardRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton(
      () => WatchDashboardUser(sl<AuthRepository>()),
    )
    ..registerLazySingleton(
      () => FetchPendingReceipts(sl<DashboardRepository>()),
    )
    ..registerFactory(
      () => DashboardCubit(
        repository: sl<DashboardRepository>(),
        watchDashboardUser: sl<WatchDashboardUser>(),
      ),
    )
    ..registerFactory(
      () => PendingReceiptsCubit(
        fetchPendingReceipts: sl<FetchPendingReceipts>(),
      ),
    );
}

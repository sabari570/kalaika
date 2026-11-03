import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/features/batches/data/datasources/batch_remote_datasource.dart';
import 'package:feemanager/features/batches/data/repositories/batch_repository_impl.dart';
import 'package:feemanager/features/batches/domain/repositories/batch_repository.dart';
import 'package:feemanager/features/batches/domain/usecases/create_batch.dart';
import 'package:feemanager/features/batches/domain/usecases/deactivate_batch.dart';
import 'package:feemanager/features/batches/domain/usecases/delete_batch.dart';
import 'package:feemanager/features/batches/domain/usecases/get_batch.dart';
import 'package:feemanager/features/batches/domain/usecases/update_batch.dart';
import 'package:feemanager/features/batches/domain/usecases/watch_batches.dart';
import 'package:feemanager/features/batches/presentation/cubit/batch_form_cubit.dart';
import 'package:feemanager/features/branches/data/datasources/branch_remote_datasource.dart';
import 'package:feemanager/features/branches/data/repositories/branch_repository_impl.dart';
import 'package:feemanager/features/branches/domain/repositories/branch_repository.dart';
import 'package:feemanager/features/branches/domain/usecases/create_branch.dart';
import 'package:feemanager/features/branches/domain/usecases/delete_branch.dart';
import 'package:feemanager/features/branches/domain/usecases/get_branch.dart';
import 'package:feemanager/features/branches/domain/usecases/update_branch.dart';
import 'package:feemanager/features/branches/domain/usecases/watch_branches.dart';
import 'package:feemanager/features/branches/presentation/cubit/branch_detail_cubit.dart';
import 'package:feemanager/features/branches/presentation/cubit/branch_form_cubit.dart';
import 'package:feemanager/features/branches/presentation/cubit/branch_list_cubit.dart';

/// Registers branch and batch dependencies.
void configureBranchesDependencies() {
  sl
    ..registerLazySingleton(BranchRemoteDataSource.new)
    ..registerLazySingleton(BatchRemoteDataSource.new)
    ..registerLazySingleton<BranchRepository>(
      () => BranchRepositoryImpl(
        remoteDataSource: sl<BranchRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton<BatchRepository>(
      () => BatchRepositoryImpl(
        remoteDataSource: sl<BatchRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton(() => WatchBranches(sl<BranchRepository>()))
    ..registerLazySingleton(() => GetBranch(sl<BranchRepository>()))
    ..registerLazySingleton(() => CreateBranch(sl<BranchRepository>()))
    ..registerLazySingleton(() => UpdateBranch(sl<BranchRepository>()))
    ..registerLazySingleton(() => DeleteBranch(sl<BranchRepository>()))
    ..registerLazySingleton(() => GetBatch(sl<BatchRepository>()))
    ..registerLazySingleton(() => WatchBatches(sl<BatchRepository>()))
    ..registerLazySingleton(() => CreateBatch(sl<BatchRepository>()))
    ..registerLazySingleton(() => UpdateBatch(sl<BatchRepository>()))
    ..registerLazySingleton(() => DeleteBatch(sl<BatchRepository>()))
    ..registerLazySingleton(() => DeactivateBatch(sl<BatchRepository>()))
    ..registerFactory(
      () => BranchListCubit(
        watchBranches: sl<WatchBranches>(),
        deleteBranch: sl<DeleteBranch>(),
      ),
    )
    ..registerFactory(
      () => BranchFormCubit(
        getBranch: sl<GetBranch>(),
        createBranch: sl<CreateBranch>(),
        updateBranch: sl<UpdateBranch>(),
      ),
    )
    ..registerFactory(
      () => BranchDetailCubit(
        getBranch: sl<GetBranch>(),
        watchBatches: sl<WatchBatches>(),
      ),
    )
    ..registerFactory(
      () => BatchFormCubit(
        getBatch: sl<GetBatch>(),
        createBatch: sl<CreateBatch>(),
        updateBatch: sl<UpdateBatch>(),
        deleteBatch: sl<DeleteBatch>(),
        deactivateBatch: sl<DeactivateBatch>(),
      ),
    );
}

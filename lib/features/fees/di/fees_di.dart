import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/features/fees/data/datasources/payment_functions_datasource.dart';
import 'package:feemanager/features/fees/data/datasources/payment_remote_datasource.dart';
import 'package:feemanager/features/fees/data/repositories/payment_repository_impl.dart';
import 'package:feemanager/features/fees/domain/repositories/payment_repository.dart';
import 'package:feemanager/features/fees/domain/usecases/generate_receipt.dart';
import 'package:feemanager/features/fees/domain/usecases/watch_monthly_fees.dart';
import 'package:feemanager/features/fees/presentation/cubit/fee_tracker_cubit.dart';

/// Registers fee tracker dependencies.
void configureFeesDependencies() {
  sl
    ..registerLazySingleton(PaymentRemoteDataSource.new)
    ..registerLazySingleton(PaymentFunctionsDataSource.new)
    ..registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl(
        remoteDataSource: sl<PaymentRemoteDataSource>(),
        functionsDataSource: sl<PaymentFunctionsDataSource>(),
      ),
    )
    ..registerLazySingleton(
      () => WatchActiveStudentsForFees(sl<PaymentRepository>()),
    )
    ..registerLazySingleton(
      () => WatchMonthlyPayments(sl<PaymentRepository>()),
    )
    ..registerLazySingleton(
      () => GenerateReceipt(sl<PaymentRepository>()),
    )
    ..registerFactory(
      () => FeeTrackerCubit(
        watchActiveStudents: sl<WatchActiveStudentsForFees>(),
        watchMonthlyPayments: sl<WatchMonthlyPayments>(),
        generateReceipt: sl<GenerateReceipt>(),
      ),
    );
}

import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/features/fees/data/datasources/payment_remote_datasource.dart';
import 'package:feemanager/features/fees/data/repositories/payment_repository_impl.dart';
import 'package:feemanager/features/fees/domain/repositories/payment_repository.dart';
import 'package:feemanager/features/fees/domain/usecases/debug_create_paid_payment.dart';
import 'package:feemanager/features/fees/domain/usecases/watch_monthly_fees.dart';
import 'package:feemanager/features/fees/presentation/cubit/fee_tracker_cubit.dart';

/// Registers fee tracker dependencies.
void configureFeesDependencies() {
  sl
    ..registerLazySingleton(PaymentRemoteDataSource.new)
    ..registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl(
        remoteDataSource: sl<PaymentRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton(
      () => WatchActiveStudentsForFees(sl<PaymentRepository>()),
    )
    ..registerLazySingleton(
      () => WatchMonthlyPayments(sl<PaymentRepository>()),
    )
    ..registerLazySingleton(
      () => DebugCreatePaidPayment(sl<PaymentRepository>()),
    )
    ..registerFactory(
      () => FeeTrackerCubit(
        watchActiveStudents: sl<WatchActiveStudentsForFees>(),
        watchMonthlyPayments: sl<WatchMonthlyPayments>(),
        debugCreatePaidPayment: sl<DebugCreatePaidPayment>(),
      ),
    );
}

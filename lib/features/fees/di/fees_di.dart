import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/features/fees/data/datasources/payment_remote_datasource.dart';
import 'package:feemanager/features/fees/data/datasources/payment_write_datasource.dart';
import 'package:feemanager/features/fees/data/repositories/payment_repository_impl.dart';
import 'package:feemanager/features/fees/domain/repositories/payment_repository.dart';
import 'package:feemanager/features/fees/domain/usecases/payment_receipt_actions.dart';
import 'package:feemanager/features/fees/domain/usecases/record_payment_and_receipt.dart';
import 'package:feemanager/features/fees/domain/usecases/watch_monthly_fees.dart';
import 'package:feemanager/features/fees/presentation/cubit/fee_tracker_cubit.dart';

/// Registers fee tracker dependencies.
void configureFeesDependencies() {
  sl
    ..registerLazySingleton(PaymentRemoteDataSource.new)
    ..registerLazySingleton(PaymentWriteDataSource.new)
    ..registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl(
        remoteDataSource: sl<PaymentRemoteDataSource>(),
        writeDataSource: sl<PaymentWriteDataSource>(),
      ),
    )
    ..registerLazySingleton(
      () => WatchActiveStudentsForFees(sl<PaymentRepository>()),
    )
    ..registerLazySingleton(
      () => WatchMonthlyPayments(sl<PaymentRepository>()),
    )
    ..registerLazySingleton(
      () => RecordPaymentAndReceipt(sl<PaymentRepository>()),
    )
    ..registerLazySingleton(
      () => MarkReceiptSent(sl<PaymentRepository>()),
    )
    ..registerLazySingleton(
      () => BuildReceiptPdf(sl<PaymentRepository>()),
    )
    ..registerLazySingleton(
      () => BuildReceiptShareMessage(sl<PaymentRepository>()),
    )
    ..registerLazySingleton(
      () => VoidPayment(sl<PaymentRepository>()),
    )
    ..registerFactory(
      () => FeeTrackerCubit(
        watchActiveStudents: sl<WatchActiveStudentsForFees>(),
        watchMonthlyPayments: sl<WatchMonthlyPayments>(),
        recordPaymentAndReceipt: sl<RecordPaymentAndReceipt>(),
        markReceiptSent: sl<MarkReceiptSent>(),
        buildReceiptPdf: sl<BuildReceiptPdf>(),
        buildReceiptShareMessage: sl<BuildReceiptShareMessage>(),
        voidPayment: sl<VoidPayment>(),
      ),
    );
}

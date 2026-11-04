import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/dashboard/domain/usecases/dashboard_usecases.dart';
import 'package:feemanager/features/dashboard/presentation/cubit/pending_receipts_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Loads pending receipt rows when the review screen opens.
class PendingReceiptsCubit extends Cubit<PendingReceiptsState> {
  /// Creates the cubit.
  PendingReceiptsCubit({required this.fetchPendingReceipts})
    : super(const PendingReceiptsLoading());

  final FetchPendingReceipts fetchPendingReceipts;

  /// Loads pending rows for [monthKey].
  Future<void> started(String monthKey) async {
    emit(const PendingReceiptsLoading());
    final result = await fetchPendingReceipts(
      FetchPendingReceiptsParams(monthKey: monthKey),
    );
    switch (result) {
      case Success(:final value):
        emit(PendingReceiptsLoaded(value));
      case Err(:final failure):
        emit(PendingReceiptsFailure(failure.message));
    }
  }
}

import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/failure.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/features/auth/domain/repositories/auth_repository.dart';
import 'package:feemanager/features/dashboard/domain/entities/pending_receipt_item.dart';
import 'package:feemanager/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Streams the signed-in user for the dashboard header.
class WatchDashboardUser implements StreamUseCase<AppUser, NoParams> {
  /// Creates the use case.
  WatchDashboardUser(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Stream<Result<AppUser>> call(NoParams params) {
    return _authRepository
        .watchAuthUser()
        .where((user) => user != null)
        .cast<AppUser>()
        .map(Success<AppUser>.new);
  }
}

/// Loads pending receipt rows for a month (on demand).
class FetchPendingReceipts
    implements UseCase<List<PendingReceiptItem>, FetchPendingReceiptsParams> {
  /// Creates the use case.
  FetchPendingReceipts(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Result<List<PendingReceiptItem>>> call(
    FetchPendingReceiptsParams params,
  ) async {
    try {
      final items = await _repository.fetchPendingReceipts(params.monthKey);
      return Success<List<PendingReceiptItem>>(items);
    } on Object {
      return const Err<List<PendingReceiptItem>>(
        UnknownFailure(AppStrings.pendingReceiptsLoadFailed),
      );
    }
  }
}

/// Parameters for [FetchPendingReceipts].
class FetchPendingReceiptsParams {
  /// Creates parameters.
  const FetchPendingReceiptsParams({required this.monthKey});

  /// Month key `yyyy-MM`.
  final String monthKey;
}

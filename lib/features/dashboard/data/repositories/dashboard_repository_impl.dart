import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:feemanager/features/dashboard/domain/entities/monthly_summary.dart';
import 'package:feemanager/features/dashboard/domain/entities/pending_receipt_item.dart';
import 'package:feemanager/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Firestore implementation of [DashboardRepository].
class DashboardRepositoryImpl implements DashboardRepository {
  /// Creates the repository.
  DashboardRepositoryImpl({required this.remoteDataSource});

  /// Remote Firestore access.
  final DashboardRemoteDataSource remoteDataSource;

  @override
  Stream<MonthlySummary> watchMonthlySummary(String monthKey) {
    return remoteDataSource.watchMonthlySummary(monthKey);
  }

  @override
  Stream<List<Branch>> watchBranches() {
    return remoteDataSource.watchBranches();
  }

  @override
  Stream<List<Batch>> watchActiveBatches() {
    return remoteDataSource.watchActiveBatches();
  }

  @override
  Future<List<PendingReceiptItem>> fetchPendingReceipts(String monthKey) {
    return remoteDataSource.fetchPendingReceipts(monthKey);
  }
}

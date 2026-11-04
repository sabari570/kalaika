import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:feemanager/features/dashboard/domain/entities/monthly_summary.dart';
import 'package:feemanager/features/dashboard/domain/entities/pending_receipt_item.dart';

/// Dashboard reads backed by Firestore.
abstract class DashboardRepository {
  /// Live monthly summary for [monthKey].
  Stream<MonthlySummary> watchMonthlySummary(String monthKey);

  /// Live branch list.
  Stream<List<Branch>> watchBranches();

  /// Live active batches for the signed-in teacher.
  Stream<List<Batch>> watchActiveBatches();

  /// Paid payments awaiting receipt delivery for [monthKey].
  Future<List<PendingReceiptItem>> fetchPendingReceipts(String monthKey);
}

/// Builds [DashboardSnapshot] from Firestore entities.
abstract final class DashboardSnapshotBuilder {
  /// Combines summary, branches, and batches into a dashboard model.
  static DashboardSnapshot build({
    required String monthKey,
    required MonthlySummary summary,
    required List<Branch> branches,
    required List<Batch> batches,
  }) {
    var totalExpected = 0;
    var activeStudents = 0;
    for (final batch in batches) {
      totalExpected += batch.expectedMonthlyTotal;
      activeStudents += batch.studentCount;
    }

    final batchesByBranch = <String, List<Batch>>{};
    for (final batch in batches) {
      batchesByBranch.putIfAbsent(batch.branchId, () => <Batch>[]).add(batch);
    }
    for (final list in batchesByBranch.values) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }

    final sections = <DashboardBranchSection>[];
    for (final branch in branches) {
      final branchBatches = batchesByBranch[branch.id] ?? <Batch>[];
      var branchCollected = 0;
      var branchExpected = 0;
      final rows = <DashboardBatchRow>[];
      for (final batch in branchBatches) {
        branchExpected += batch.expectedMonthlyTotal;
        final batchSummary = summary.byBatch[batch.id];
        final collected = batchSummary?.collected ?? 0;
        final paid = batchSummary?.paidCount ?? 0;
        branchCollected += collected;
        rows.add(
          DashboardBatchRow(
            batch: batch,
            collected: collected,
            paidCount: paid,
          ),
        );
      }
      sections.add(
        DashboardBranchSection(
          branch: branch,
          collected: branchCollected,
          expected: branchExpected,
          batches: rows,
        ),
      );
    }

    return DashboardSnapshot(
      monthKey: monthKey,
      summary: summary,
      branchSections: sections,
      totalExpected: totalExpected,
      activeStudents: activeStudents,
    );
  }
}

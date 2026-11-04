import 'package:equatable/equatable.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/dashboard/domain/entities/monthly_summary.dart';

/// One batch row on the dashboard branch card.
class DashboardBatchRow extends Equatable {
  /// Creates a batch row view model.
  const DashboardBatchRow({
    required this.batch,
    required this.collected,
    required this.paidCount,
  });

  /// Batch entity.
  final Batch batch;

  /// Collected rupees this month.
  final int collected;

  /// Paid student count this month.
  final int paidCount;

  @override
  List<Object?> get props => <Object?>[batch, collected, paidCount];
}

/// Branch section on the dashboard.
class DashboardBranchSection extends Equatable {
  /// Creates a branch section.
  const DashboardBranchSection({
    required this.branch,
    required this.collected,
    required this.expected,
    required this.batches,
  });

  /// Branch entity.
  final Branch branch;

  /// Collected rupees in this branch for the month.
  final int collected;

  /// Expected rupees from active students.
  final int expected;

  /// Active batches in the branch.
  final List<DashboardBatchRow> batches;

  @override
  List<Object?> get props => <Object?>[
    branch,
    collected,
    expected,
    batches,
  ];
}

/// Combined dashboard metrics and branch cards.
class DashboardSnapshot extends Equatable {
  /// Creates a dashboard snapshot.
  const DashboardSnapshot({
    required this.monthKey,
    required this.summary,
    required this.branchSections,
    required this.totalExpected,
    required this.activeStudents,
  });

  /// Selected month key.
  final String monthKey;

  /// Monthly rollup document values.
  final MonthlySummary summary;

  /// Branch cards with nested batch rows.
  final List<DashboardBranchSection> branchSections;

  /// Sum of active batch expected monthly totals.
  final int totalExpected;

  /// Sum of active student counts.
  final int activeStudents;

  /// Pending rupees for the month.
  int get pendingAmount {
    final pending = totalExpected - summary.collected;
    return pending < 0 ? 0 : pending;
  }

  /// Receipts awaiting delivery.
  int get pendingReceiptCount {
    final pending = summary.paidCount - summary.sentCount;
    return pending < 0 ? 0 : pending;
  }

  /// Collection progress from 0 to 1.
  double get collectionProgress {
    if (totalExpected <= 0) {
      return 0;
    }
    return summary.collected / totalExpected;
  }

  @override
  List<Object?> get props => <Object?>[
    monthKey,
    summary,
    branchSections,
    totalExpected,
    activeStudents,
  ];
}

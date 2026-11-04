import 'package:equatable/equatable.dart';

/// Rollup counters for one batch in a month.
class BatchMonthSummary extends Equatable {
  /// Creates batch summary values.
  const BatchMonthSummary({
    required this.batchId,
    required this.branchId,
    required this.collected,
    required this.paidCount,
    required this.sentCount,
  });

  /// Batch document id.
  final String batchId;

  /// Parent branch id.
  final String branchId;

  /// Collected rupees for the batch.
  final int collected;

  /// Paid student count.
  final int paidCount;

  /// Sent receipt count.
  final int sentCount;

  @override
  List<Object?> get props => <Object?>[
    batchId,
    branchId,
    collected,
    paidCount,
    sentCount,
  ];
}

/// Monthly summary document for the signed-in teacher.
class MonthlySummary extends Equatable {
  /// Creates a monthly summary.
  const MonthlySummary({
    required this.monthKey,
    required this.collected,
    required this.paidCount,
    required this.sentCount,
    required this.byBatch,
  });

  /// Empty summary for a month with no payments.
  factory MonthlySummary.empty(String monthKey) {
    return MonthlySummary(
      monthKey: monthKey,
      collected: 0,
      paidCount: 0,
      sentCount: 0,
      byBatch: const <String, BatchMonthSummary>{},
    );
  }

  /// Month key `yyyy-MM`.
  final String monthKey;

  /// Total collected rupees.
  final int collected;

  /// Paid student count across batches.
  final int paidCount;

  /// Sent receipt count.
  final int sentCount;

  /// Per-batch rollups keyed by batch id.
  final Map<String, BatchMonthSummary> byBatch;

  @override
  List<Object?> get props => <Object?>[
    monthKey,
    collected,
    paidCount,
    sentCount,
    byBatch,
  ];
}

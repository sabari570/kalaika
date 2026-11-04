import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';

/// Payment fields used for summary rollups.
class PaymentSummarySnapshot {
  /// Creates a snapshot.
  const PaymentSummarySnapshot({
    required this.month,
    required this.amount,
    required this.status,
    required this.voided,
    required this.batchId,
    required this.branchId,
  });

  /// Builds from a payment document map.
  factory PaymentSummarySnapshot.fromMap(Map<String, dynamic> data) {
    return PaymentSummarySnapshot(
      month: data[FirestoreKeys.month] as String? ?? '',
      amount: (data[FirestoreKeys.amount] as num?)?.toInt() ?? 0,
      status: data[FirestoreKeys.status] as String? ?? '',
      voided: data[FirestoreKeys.voided] as bool? ?? false,
      batchId: data[FirestoreKeys.batchId] as String? ?? '',
      branchId: data[FirestoreKeys.branchId] as String? ?? '',
    );
  }

  /// Month key.
  final String month;

  /// Amount in rupees.
  final int amount;

  /// Status value.
  final String status;

  /// Void flag.
  final bool voided;

  /// Batch id.
  final String batchId;

  /// Branch id.
  final String branchId;
}

/// Delta counters for monthly summaries.
class SummaryDelta {
  /// Creates a delta.
  const SummaryDelta({
    required this.collected,
    required this.paidCount,
    required this.sentCount,
  });

  /// Zero delta.
  const SummaryDelta.zero()
    : collected = 0,
      paidCount = 0,
      sentCount = 0;

  /// Collected rupees change.
  final int collected;

  /// Paid count change.
  final int paidCount;

  /// Sent count change.
  final int sentCount;
}

/// Summary rollup helpers ported from Cloud Functions.
abstract final class SummaryDeltaUtils {
  /// Contribution of one payment to summary totals.
  static SummaryDelta summaryContribution(PaymentSummarySnapshot? payment) {
    if (payment == null ||
        payment.voided ||
        payment.month.isEmpty) {
      return const SummaryDelta.zero();
    }
    final active =
        payment.status == FirestoreKeys.statusPaid ||
        payment.status == FirestoreKeys.statusSent;
    if (!active) {
      return const SummaryDelta.zero();
    }
    return SummaryDelta(
      collected: payment.amount,
      paidCount: 1,
      sentCount: payment.status == FirestoreKeys.statusSent ? 1 : 0,
    );
  }

  /// Sums two deltas for grouped summary writes.
  static SummaryDelta combine(SummaryDelta a, SummaryDelta b) {
    return SummaryDelta(
      collected: a.collected + b.collected,
      paidCount: a.paidCount + b.paidCount,
      sentCount: a.sentCount + b.sentCount,
    );
  }

  /// Difference between two payment snapshots.
  static SummaryDelta deltaSummary(
    PaymentSummarySnapshot? before,
    PaymentSummarySnapshot? after,
  ) {
    final beforeContribution = summaryContribution(before);
    final afterContribution = summaryContribution(after);
    return SummaryDelta(
      collected:
          afterContribution.collected - beforeContribution.collected,
      paidCount: afterContribution.paidCount - beforeContribution.paidCount,
      sentCount: afterContribution.sentCount - beforeContribution.sentCount,
    );
  }

  /// Firestore merge map for monthly summary updates.
  static Map<String, Object?> buildSummaryUpdate({
    required String monthKey,
    required String batchId,
    required String branchId,
    required SummaryDelta delta,
  }) {
    if (delta.collected == 0 &&
        delta.paidCount == 0 &&
        delta.sentCount == 0) {
      return <String, Object?>{};
    }
    final update = <String, Object?>{
      FirestoreKeys.month: monthKey,
      FirestoreKeys.updatedAt: FieldValue.serverTimestamp(),
    };
    if (delta.collected != 0) {
      update[FirestoreKeys.collected] =
          FieldValue.increment(delta.collected);
    }
    if (delta.paidCount != 0) {
      update[FirestoreKeys.paidCount] =
          FieldValue.increment(delta.paidCount);
    }
    if (delta.sentCount != 0) {
      update[FirestoreKeys.sentCount] =
          FieldValue.increment(delta.sentCount);
    }
    final batchPrefix = '${FirestoreKeys.byBatch}.$batchId';
    if (delta.collected != 0) {
      update['$batchPrefix.${FirestoreKeys.collected}'] =
          FieldValue.increment(delta.collected);
    }
    if (delta.paidCount != 0) {
      update['$batchPrefix.${FirestoreKeys.paidCount}'] =
          FieldValue.increment(delta.paidCount);
    }
    if (delta.sentCount != 0) {
      update['$batchPrefix.${FirestoreKeys.sentCount}'] =
          FieldValue.increment(delta.sentCount);
    }
    update['$batchPrefix.${FirestoreKeys.branchId}'] = branchId;
    return update;
  }
}

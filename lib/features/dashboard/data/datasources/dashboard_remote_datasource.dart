import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/core/utils/firebase_user_scope.dart';
import 'package:feemanager/features/batches/data/models/batch_model.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/branches/data/models/branch_model.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/dashboard/domain/entities/monthly_summary.dart';
import 'package:feemanager/features/dashboard/domain/entities/pending_receipt_item.dart';

/// Firestore reads for the dashboard and pending receipt list.
class DashboardRemoteDataSource {
  /// Creates the data source.
  DashboardRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Streams the monthly summary document.
  Stream<MonthlySummary> watchMonthlySummary(String monthKey) {
    final uid = FirebaseUserScope.requireUid();
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.summaries)
        .doc(monthKey)
        .snapshots()
        .map((snapshot) => _readSummary(monthKey, snapshot.data()));
  }

  /// Streams branches ordered by name.
  Stream<List<Branch>> watchBranches() {
    final uid = FirebaseUserScope.requireUid();
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.branches)
        .orderBy(FirestoreKeys.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(BranchModel.fromSnapshot)
              .map((model) => model.toEntity())
              .where((branch) => branch.isActive)
              .toList(),
        );
  }

  /// Streams all active batches for the signed-in teacher.
  Stream<List<Batch>> watchActiveBatches() {
    final uid = FirebaseUserScope.requireUid();
    return _firestore
        .collectionGroup(FirestoreKeys.batches)
        .where(FirestoreKeys.ownerId, isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(BatchModel.fromSnapshot)
              .map((model) => model.toEntity())
              .where((batch) => batch.isActive)
              .toList(),
        );
  }

  /// Loads paid payments whose receipts have not been sent.
  Future<List<PendingReceiptItem>> fetchPendingReceipts(
    String monthKey,
  ) async {
    final uid = FirebaseUserScope.requireUid();
    final paymentsSnap = await _firestore
        .collectionGroup(FirestoreKeys.payments)
        .where(FirestoreKeys.ownerId, isEqualTo: uid)
        .where(FirestoreKeys.month, isEqualTo: monthKey)
        .where(FirestoreKeys.status, isEqualTo: FirestoreKeys.statusPaid)
        .get();
    final batches = await watchActiveBatches().first;
    final batchNames = <String, String>{
      for (final batch in batches) batch.id: batch.name,
    };
    return paymentsSnap.docs.map((doc) {
      final data = doc.data();
      final batchId = data[FirestoreKeys.batchId] as String? ?? '';
      return PendingReceiptItem(
        paymentId: doc.id,
        studentName: data[FirestoreKeys.studentName] as String? ?? '',
        guardianName: data[FirestoreKeys.guardianName] as String?,
        branchId: data[FirestoreKeys.branchId] as String? ?? '',
        batchId: batchId,
        batchName: batchNames[batchId] ?? batchId,
        amount: (data[FirestoreKeys.amount] as num?)?.toInt() ?? 0,
      );
    }).toList()
      ..sort((a, b) => a.batchName.compareTo(b.batchName));
  }

  MonthlySummary _readSummary(
    String monthKey,
    Map<String, dynamic>? data,
  ) {
    if (data == null) {
      return MonthlySummary.empty(monthKey);
    }
    final byBatchRaw =
        data[FirestoreKeys.byBatch] as Map<String, dynamic>? ??
        <String, dynamic>{};
    final byBatch = <String, BatchMonthSummary>{};
    for (final entry in byBatchRaw.entries) {
      final batchId = entry.key;
      final batchMap =
          entry.value as Map<String, dynamic>? ?? <String, dynamic>{};
      byBatch[batchId] = BatchMonthSummary(
        batchId: batchId,
        branchId: batchMap[FirestoreKeys.branchId] as String? ?? '',
        collected: (batchMap[FirestoreKeys.collected] as num?)?.toInt() ?? 0,
        paidCount: (batchMap[FirestoreKeys.paidCount] as num?)?.toInt() ?? 0,
        sentCount: (batchMap[FirestoreKeys.sentCount] as num?)?.toInt() ?? 0,
      );
    }
    return MonthlySummary(
      monthKey: monthKey,
      collected: (data[FirestoreKeys.collected] as num?)?.toInt() ?? 0,
      paidCount: (data[FirestoreKeys.paidCount] as num?)?.toInt() ?? 0,
      sentCount: (data[FirestoreKeys.sentCount] as num?)?.toInt() ?? 0,
      byBatch: byBatch,
    );
  }
}

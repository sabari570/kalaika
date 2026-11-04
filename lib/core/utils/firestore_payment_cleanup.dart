import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/core/utils/summary_delta_utils.dart';

/// Voids and removes payment documents while reversing summary rollups.
abstract final class FirestorePaymentCleanup {
  static const int _chunkSize = 400;

  /// Voids each payment, updates summaries, then deletes the documents.
  static Future<void> revertSummariesAndDeletePayments({
    required FirebaseFirestore firestore,
    required String uid,
    required String branchId,
    required String batchId,
    required Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> paymentDocs,
  }) async {
    final docs = paymentDocs.toList();
    if (docs.isEmpty) {
      return;
    }
    for (final doc in docs) {
      await _voidPaymentIfNeeded(
        firestore: firestore,
        uid: uid,
        branchId: branchId,
        batchId: batchId,
        paymentRef: doc.reference,
      );
    }
    await _deleteReferencesInChunks(
      firestore,
      docs.map((doc) => doc.reference),
    );
  }

  /// Deletes documents in Firestore write batches.
  static Future<void> deleteDocumentsInChunks(
    FirebaseFirestore firestore,
    Iterable<DocumentReference<Map<String, dynamic>>> references,
  ) {
    return _deleteReferencesInChunks(firestore, references);
  }

  static Future<void> _voidPaymentIfNeeded({
    required FirebaseFirestore firestore,
    required String uid,
    required String branchId,
    required String batchId,
    required DocumentReference<Map<String, dynamic>> paymentRef,
  }) async {
    await firestore.runTransaction((transaction) async {
      final snap = await transaction.get(paymentRef);
      if (!snap.exists) {
        return;
      }
      final beforeData = snap.data() ?? <String, dynamic>{};
      final before = PaymentSummarySnapshot.fromMap(beforeData);
      if (before.voided) {
        return;
      }
      transaction.update(paymentRef, <String, Object?>{
        FirestoreKeys.voided: true,
        FirestoreKeys.status: FirestoreKeys.statusVoided,
      });
      final afterData = Map<String, dynamic>.from(beforeData)
        ..[FirestoreKeys.voided] = true
        ..[FirestoreKeys.status] = FirestoreKeys.statusVoided;
      final after = PaymentSummarySnapshot.fromMap(afterData);
      final delta = SummaryDeltaUtils.deltaSummary(before, after);
      final monthKey = before.month;
      if (monthKey.isEmpty) {
        return;
      }
      final summaryUpdate = SummaryDeltaUtils.buildSummaryUpdate(
        monthKey: monthKey,
        batchId: batchId,
        branchId: branchId,
        delta: delta,
      );
      if (summaryUpdate.isNotEmpty) {
        transaction.set(
          _summaryRef(firestore, uid, monthKey),
          summaryUpdate,
          SetOptions(merge: true),
        );
      }
    });
  }

  static DocumentReference<Map<String, dynamic>> _summaryRef(
    FirebaseFirestore firestore,
    String uid,
    String monthKey,
  ) {
    return firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.summaries)
        .doc(monthKey);
  }

  static Future<void> _deleteReferencesInChunks(
    FirebaseFirestore firestore,
    Iterable<DocumentReference<Map<String, dynamic>>> references,
  ) async {
    final refs = references.toList();
    var index = 0;
    while (index < refs.length) {
      final end = index + _chunkSize > refs.length
          ? refs.length
          : index + _chunkSize;
      final batch = firestore.batch();
      for (var i = index; i < end; i++) {
        batch.delete(refs[i]);
      }
      try {
        await batch.commit();
      } on FirebaseException catch (error) {
        if (error.code == 'permission-denied') {
          return;
        }
        rethrow;
      }
      index = end;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/core/utils/firebase_user_scope.dart';
import 'package:feemanager/features/batches/data/models/batch_model.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/batches/domain/entities/batch_draft.dart';
import 'package:feemanager/features/branches/data/models/branch_model.dart';

/// Firestore access for batches under a branch.
class BatchRemoteDataSource {
  /// Creates the data source.
  BatchRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _branchesRef(String uid) {
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.branches);
  }

  CollectionReference<Map<String, dynamic>> _batchesRef(
    String uid,
    String branchId,
  ) {
    return _branchesRef(uid).doc(branchId).collection(FirestoreKeys.batches);
  }

  CollectionReference<Map<String, dynamic>> _studentsRef(
    String uid,
    String branchId,
    String batchId,
  ) {
    return _batchesRef(uid, branchId).doc(batchId).collection(
      FirestoreKeys.students,
    );
  }

  /// Recomputes student counters on every batch in [branchId] and the branch.
  Future<void> reconcileStudentCounters(String branchId) async {
    final uid = FirebaseUserScope.requireUid();
    final batchesSnap = await _batchesRef(uid, branchId)
        .where(FirestoreKeys.isActive, isEqualTo: true)
        .get();
    var branchStudentTotal = 0;
    for (final batchDoc in batchesSnap.docs) {
      branchStudentTotal += await _syncBatchStudentCounters(
        uid: uid,
        branchId: branchId,
        batchId: batchDoc.id,
      );
    }
    await _branchesRef(uid).doc(branchId).update(<String, Object?>{
      FirestoreKeys.studentCount: branchStudentTotal,
    });
  }

  /// Sets batch counters from active students; returns active student count.
  Future<int> _syncBatchStudentCounters({
    required String uid,
    required String branchId,
    required String batchId,
  }) async {
    final studentsSnap = await _studentsRef(uid, branchId, batchId)
        .where(FirestoreKeys.isActive, isEqualTo: true)
        .get();
    var feeTotal = 0;
    for (final doc in studentsSnap.docs) {
      feeTotal +=
          (doc.data()[FirestoreKeys.monthlyFee] as num?)?.toInt() ?? 0;
    }
    await _batchesRef(uid, branchId).doc(batchId).update(<String, Object?>{
      FirestoreKeys.studentCount: studentsSnap.size,
      FirestoreKeys.expectedMonthlyTotal: feeTotal,
    });
    return studentsSnap.size;
  }

  /// Streams active batches for a branch ordered by name.
  Stream<List<Batch>> watchBatches(String branchId) {
    final uid = FirebaseUserScope.requireUid();
    return _batchesRef(uid, branchId)
        .where(FirestoreKeys.isActive, isEqualTo: true)
        .orderBy(FirestoreKeys.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(BatchModel.fromSnapshot)
              .map((model) => model.toEntity())
              .toList(),
        );
  }

  /// Reads one batch document.
  Future<Batch> getBatch(String branchId, String batchId) async {
    final uid = FirebaseUserScope.requireUid();
    final snapshot = await _batchesRef(uid, branchId).doc(batchId).get();
    if (!snapshot.exists) {
      throw StateError(AppStrings.batchNotFound);
    }
    return BatchModel.fromSnapshot(snapshot).toEntity();
  }

  /// Creates a batch and increments branch batch count.
  Future<Batch> createBatch(String branchId, BatchDraft draft) async {
    _validateDraft(draft);
    final uid = FirebaseUserScope.requireUid();
    final branchSnap = await _branchesRef(uid).doc(branchId).get();
    if (!branchSnap.exists) {
      throw StateError(AppStrings.branchNotFound);
    }
    final branch = BranchModel.fromSnapshot(branchSnap);
    final batchRef = _batchesRef(uid, branchId).doc();
    await _firestore.runTransaction((transaction) async {
      transaction
        ..set(
          batchRef,
          BatchModel.createMap(
            ownerId: uid,
            branchId: branchId,
            branchName: branch.name,
            draft: draft,
          ),
        )
        ..update(branchSnap.reference, <String, Object?>{
          FirestoreKeys.batchCount: FieldValue.increment(1),
        });
    });
    final saved = await batchRef.get();
    return BatchModel.fromSnapshot(saved).toEntity();
  }

  /// Updates batch fields and optionally student monthly fees.
  Future<Batch> updateBatch(
    String branchId,
    String batchId,
    BatchDraft draft,
  ) async {
    _validateDraft(draft);
    final uid = FirebaseUserScope.requireUid();
    final batchRef = _batchesRef(uid, branchId).doc(batchId);
    final existing = await batchRef.get();
    if (!existing.exists) {
      throw StateError(AppStrings.batchNotFound);
    }
    await batchRef.update(BatchModel.updateMap(draft));
    if (draft.feeApplyScope == BatchFeeApplyScope.allActiveStudents) {
      await _applyFeeToActiveStudents(
        uid: uid,
        branchId: branchId,
        batchId: batchId,
        fee: draft.defaultFee,
      );
    }
    final saved = await batchRef.get();
    return BatchModel.fromSnapshot(saved).toEntity();
  }

  /// Deletes a batch with no students and decrements branch batch count.
  Future<void> deleteBatch(String branchId, String batchId) async {
    final uid = FirebaseUserScope.requireUid();
    final batchRef = _batchesRef(uid, branchId).doc(batchId);
    final branchRef = _branchesRef(uid).doc(branchId);
    final snapshot = await batchRef.get();
    if (!snapshot.exists) {
      return;
    }
    final batch = BatchModel.fromSnapshot(snapshot);
    if (batch.studentCount > 0) {
      throw StateError(AppStrings.cannotDeleteBatchWithStudents);
    }
    await _firestore.runTransaction((transaction) async {
      transaction
        ..delete(batchRef)
        ..update(branchRef, <String, Object?>{
          FirestoreKeys.batchCount: FieldValue.increment(-1),
        });
    });
  }

  /// Sets the batch inactive flag on the document.
  Future<void> deactivateBatch(String branchId, String batchId) async {
    final uid = FirebaseUserScope.requireUid();
    await _batchesRef(uid, branchId).doc(batchId).update(<String, Object?>{
      FirestoreKeys.isActive: false,
    });
  }

  Future<void> _applyFeeToActiveStudents({
    required String uid,
    required String branchId,
    required String batchId,
    required int fee,
  }) async {
    final students = await _studentsRef(uid, branchId, batchId)
        .where(FirestoreKeys.isActive, isEqualTo: true)
        .get();
    if (students.docs.isEmpty) {
      await _batchesRef(uid, branchId).doc(batchId).update(<String, Object?>{
        FirestoreKeys.expectedMonthlyTotal: 0,
      });
      return;
    }
    var writeBatch = _firestore.batch();
    var ops = 0;
    var activeCount = 0;
    for (final doc in students.docs) {
      writeBatch.update(doc.reference, <String, Object?>{
        FirestoreKeys.monthlyFee: fee,
      });
      activeCount++;
      ops++;
      if (ops >= 400) {
        await writeBatch.commit();
        writeBatch = _firestore.batch();
        ops = 0;
      }
    }
    if (ops > 0) {
      await writeBatch.commit();
    }
    await _batchesRef(uid, branchId).doc(batchId).update(<String, Object?>{
      FirestoreKeys.expectedMonthlyTotal: activeCount * fee,
    });
  }

  void _validateDraft(BatchDraft draft) {
    if (draft.name.trim().isEmpty) {
      throw StateError(AppStrings.batchNameRequired);
    }
    if (draft.defaultFee <= 0) {
      throw StateError(AppStrings.batchFeeInvalid);
    }
  }
}

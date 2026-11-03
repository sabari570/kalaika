import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/core/utils/firebase_user_scope.dart';
import 'package:feemanager/features/branches/data/models/branch_model.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/branches/domain/entities/branch_draft.dart';

/// Firestore access for branches under `users/{uid}/branches`.
class BranchRemoteDataSource {
  /// Creates the data source.
  BranchRemoteDataSource({FirebaseFirestore? firestore})
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

  /// Streams branches ordered by name.
  Stream<List<Branch>> watchBranches() {
    final uid = FirebaseUserScope.requireUid();
    return _branchesRef(uid)
        .orderBy(FirestoreKeys.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(BranchModel.fromSnapshot)
              .map((model) => model.toEntity())
              .toList(),
        );
  }

  /// Reads one branch document.
  Future<Branch> getBranch(String branchId) async {
    final uid = FirebaseUserScope.requireUid();
    final snapshot = await _branchesRef(uid).doc(branchId).get();
    if (!snapshot.exists) {
      throw StateError(AppStrings.branchNotFound);
    }
    return BranchModel.fromSnapshot(snapshot).toEntity();
  }

  /// Creates a branch and returns the saved entity.
  Future<Branch> createBranch(BranchDraft draft) async {
    _validateDraft(draft);
    final uid = FirebaseUserScope.requireUid();
    final doc = _branchesRef(uid).doc();
    await doc.set(BranchModel.createMap(draft));
    final saved = await doc.get();
    return BranchModel.fromSnapshot(saved).toEntity();
  }

  /// Updates branch fields and batch branchName when renamed.
  Future<Branch> updateBranch(String branchId, BranchDraft draft) async {
    _validateDraft(draft);
    final uid = FirebaseUserScope.requireUid();
    final branchRef = _branchesRef(uid).doc(branchId);
    final existing = await branchRef.get();
    if (!existing.exists) {
      throw StateError(AppStrings.branchNotFound);
    }
    final oldName = existing.data()?[FirestoreKeys.name] as String? ?? '';
    await branchRef.update(BranchModel.updateMap(draft));
    final newName = draft.name.trim();
    if (oldName != newName) {
      await _syncBatchBranchNames(uid, branchId, newName);
    }
    final saved = await branchRef.get();
    return BranchModel.fromSnapshot(saved).toEntity();
  }

  /// Deletes a branch when it has no batches.
  Future<void> deleteBranch(String branchId) async {
    final uid = FirebaseUserScope.requireUid();
    final branchRef = _branchesRef(uid).doc(branchId);
    final snapshot = await branchRef.get();
    if (!snapshot.exists) {
      return;
    }
    final model = BranchModel.fromSnapshot(snapshot);
    if (model.batchCount > 0) {
      throw StateError(AppStrings.cannotDeleteBranchWithBatches);
    }
    await branchRef.delete();
  }

  Future<void> _syncBatchBranchNames(
    String uid,
    String branchId,
    String branchName,
  ) async {
    final batches = await _batchesRef(uid, branchId).get();
    if (batches.docs.isEmpty) {
      return;
    }
    var batch = _firestore.batch();
    var ops = 0;
    for (final doc in batches.docs) {
      batch.update(doc.reference, <String, Object?>{
        FirestoreKeys.branchName: branchName,
      });
      ops++;
      if (ops >= 400) {
        await batch.commit();
        batch = _firestore.batch();
        ops = 0;
      }
    }
    if (ops > 0) {
      await batch.commit();
    }
  }

  void _validateDraft(BranchDraft draft) {
    if (draft.name.trim().isEmpty) {
      throw StateError(AppStrings.branchNameRequired);
    }
  }
}

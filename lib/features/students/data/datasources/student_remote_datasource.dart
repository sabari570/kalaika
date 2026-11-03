import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/core/utils/firebase_user_scope.dart';
import 'package:feemanager/features/students/data/models/student_model.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:feemanager/features/students/domain/entities/student_draft.dart';
import 'package:feemanager/features/students/domain/entities/student_payment_summary.dart';
import 'package:feemanager/features/students/domain/repositories/student_repository.dart';

/// Firestore access for students under a batch.
class StudentRemoteDataSource {
  /// Creates the data source.
  StudentRemoteDataSource({FirebaseFirestore? firestore})
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
    return _batchesRef(uid, branchId)
        .doc(batchId)
        .collection(FirestoreKeys.students);
  }

  CollectionReference<Map<String, dynamic>> _paymentsRef(
    String uid,
    String branchId,
    String batchId,
  ) {
    return _batchesRef(uid, branchId)
        .doc(batchId)
        .collection(FirestoreKeys.payments);
  }

  /// Streams all students ordered by name.
  Stream<List<Student>> watchStudents(String branchId, String batchId) {
    final uid = FirebaseUserScope.requireUid();
    return _studentsRef(uid, branchId, batchId)
        .orderBy(FirestoreKeys.fullName)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(StudentModel.fromSnapshot)
              .map((model) => model.toEntity())
              .toList(),
        );
  }

  /// Reads all students once.
  Future<List<Student>> listStudents(String branchId, String batchId) async {
    final uid = FirebaseUserScope.requireUid();
    final snapshot = await _studentsRef(uid, branchId, batchId).get();
    return snapshot.docs
        .map(StudentModel.fromSnapshot)
        .map((model) => model.toEntity())
        .toList();
  }

  /// Reads one student.
  Future<Student> getStudent(
    String branchId,
    String batchId,
    String studentId,
  ) async {
    final uid = FirebaseUserScope.requireUid();
    final snapshot = await _studentsRef(
      uid,
      branchId,
      batchId,
    ).doc(studentId).get();
    if (!snapshot.exists) {
      throw StateError(AppStrings.studentNotFound);
    }
    return StudentModel.fromSnapshot(snapshot).toEntity();
  }

  /// Creates a student and increments counters.
  Future<Student> createStudent(
    String branchId,
    String batchId,
    StudentDraft draft,
  ) async {
    _validateDraft(draft);
    final uid = FirebaseUserScope.requireUid();
    final studentRef = _studentsRef(uid, branchId, batchId).doc();
    await studentRef.set(StudentModel.createMap(draft));
    await _syncBatchAndBranchCounters(uid, branchId, batchId);
    final saved = await studentRef.get();
    return StudentModel.fromSnapshot(saved).toEntity();
  }

  /// Updates a student and adjusts expected totals when the fee changes.
  Future<Student> updateStudent(
    String branchId,
    String batchId,
    String studentId,
    StudentDraft draft,
  ) async {
    _validateDraft(draft);
    final uid = FirebaseUserScope.requireUid();
    final studentRef = _studentsRef(uid, branchId, batchId).doc(studentId);
    final batchRef = _batchesRef(uid, branchId).doc(batchId);
    final existingSnap = await studentRef.get();
    if (!existingSnap.exists) {
      throw StateError(AppStrings.studentNotFound);
    }
    final existing = StudentModel.fromSnapshot(existingSnap);
    await studentRef.update(StudentModel.updateMap(draft));
    if (existing.isActive && existing.monthlyFee != draft.monthlyFee) {
      final delta = draft.monthlyFee - existing.monthlyFee;
      await batchRef.update(<String, Object?>{
        FirestoreKeys.expectedMonthlyTotal: FieldValue.increment(delta),
      });
    }
    final saved = await studentRef.get();
    return StudentModel.fromSnapshot(saved).toEntity();
  }

  /// Activates or deactivates a student and updates counters.
  Future<void> setStudentActive(
    String branchId,
    String batchId,
    String studentId, {
    required bool isActive,
  }) async {
    final uid = FirebaseUserScope.requireUid();
    final studentRef = _studentsRef(uid, branchId, batchId).doc(studentId);
    final snapshot = await studentRef.get();
    if (!snapshot.exists) {
      throw StateError(AppStrings.studentNotFound);
    }
    final existing = StudentModel.fromSnapshot(snapshot);
    if (existing.isActive == isActive) {
      return;
    }
    await studentRef.update(<String, Object?>{
      FirestoreKeys.isActive: isActive,
    });
    await _syncBatchAndBranchCounters(uid, branchId, batchId);
  }

  /// Checks duplicate WhatsApp and name in the batch.
  Future<bool> hasDuplicateStudent({
    required String branchId,
    required String batchId,
    required String fullName,
    required String whatsappNumber,
    String? excludeStudentId,
  }) async {
    final students = await listStudents(branchId, batchId);
    final key = _duplicateKey(fullName, whatsappNumber);
    for (final student in students) {
      if (student.id == excludeStudentId) {
        continue;
      }
      if (_duplicateKey(student.fullName, student.whatsappNumber) == key) {
        return true;
      }
    }
    return false;
  }

  /// Writes [drafts] in chunks and updates counters once at the end.
  Future<ImportStudentsResult> importStudents({
    required String branchId,
    required String batchId,
    required List<StudentDraft> drafts,
  }) async {
    if (drafts.isEmpty) {
      return const ImportStudentsResult(
        imported: 0,
        skipped: 0,
        failed: 0,
      );
    }
    final uid = FirebaseUserScope.requireUid();
    final studentsRef = _studentsRef(uid, branchId, batchId);
    var imported = 0;
    var index = 0;
    while (index < drafts.length) {
      final chunkEnd = index + 400 > drafts.length
          ? drafts.length
          : index + 400;
      final chunk = drafts.sublist(index, chunkEnd);
      try {
        final writeBatch = _firestore.batch();
        for (final draft in chunk) {
          _validateDraft(draft);
          final doc = studentsRef.doc();
          writeBatch.set(doc, StudentModel.createMap(draft));
        }
        await writeBatch.commit();
        imported += chunk.length;
        index = chunkEnd;
      } on Object {
        return ImportStudentsResult(
          imported: imported,
          skipped: 0,
          failed: drafts.length - imported,
        );
      }
    }
    await _syncBatchAndBranchCounters(uid, branchId, batchId);
    return ImportStudentsResult(
      imported: imported,
      skipped: 0,
      failed: 0,
    );
  }

  /// Loads the last 12 payments for a student.
  Future<List<StudentPaymentSummary>> getPaymentHistory(
    String branchId,
    String batchId,
    String studentId,
  ) async {
    final uid = FirebaseUserScope.requireUid();
    final snapshot = await _paymentsRef(uid, branchId, batchId)
        .where(FirestoreKeys.studentId, isEqualTo: studentId)
        .orderBy(FirestoreKeys.month, descending: true)
        .limit(12)
        .get();
    return snapshot.docs
        .map(StudentPaymentModel.fromSnapshot)
        .map((model) => model.toEntity())
        .toList();
  }

  void _validateDraft(StudentDraft draft) {
    if (draft.fullName.trim().isEmpty) {
      throw StateError(AppStrings.studentNameRequired);
    }
    if (draft.whatsappNumber.isEmpty) {
      throw StateError(AppStrings.whatsappRequired);
    }
    if (draft.monthlyFee <= 0) {
      throw StateError(AppStrings.studentFeeInvalid);
    }
  }

  String _duplicateKey(String name, String whatsapp) {
    return '${name.trim().toLowerCase()}|$whatsapp';
  }

  Future<void> _syncBatchAndBranchCounters(
    String uid,
    String branchId,
    String batchId,
  ) async {
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
    final batchesSnap = await _batchesRef(uid, branchId)
        .where(FirestoreKeys.isActive, isEqualTo: true)
        .get();
    var branchStudentTotal = 0;
    for (final batchDoc in batchesSnap.docs) {
      if (batchDoc.id == batchId) {
        branchStudentTotal += studentsSnap.size;
      } else {
        branchStudentTotal +=
            (batchDoc.data()[FirestoreKeys.studentCount] as num?)?.toInt() ??
            0;
      }
    }
    await _branchesRef(uid).doc(branchId).update(<String, Object?>{
      FirestoreKeys.studentCount: branchStudentTotal,
    });
  }
}

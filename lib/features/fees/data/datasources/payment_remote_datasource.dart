import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/core/utils/firebase_user_scope.dart';
import 'package:feemanager/features/fees/data/models/payment_model.dart';
import 'package:feemanager/features/fees/domain/entities/payment.dart';
import 'package:feemanager/features/students/data/models/student_model.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';

/// Firestore access for batch payments and active students.
class PaymentRemoteDataSource {
  /// Creates the data source.
  PaymentRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _batchesRef(
    String uid,
    String branchId,
  ) {
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.branches)
        .doc(branchId)
        .collection(FirestoreKeys.batches);
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

  /// Active students ordered by full name.
  Stream<List<Student>> watchActiveStudents(
    String branchId,
    String batchId,
  ) {
    final uid = FirebaseUserScope.requireUid();
    return _studentsRef(uid, branchId, batchId)
        .where(FirestoreKeys.isActive, isEqualTo: true)
        .orderBy(FirestoreKeys.fullName)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(StudentModel.fromSnapshot)
              .map((model) => model.toEntity())
              .toList(),
        );
  }

  /// Payments for one month in a batch.
  Stream<List<Payment>> watchPaymentsForMonth(
    String branchId,
    String batchId,
    String monthKey,
  ) {
    final uid = FirebaseUserScope.requireUid();
    return _paymentsRef(uid, branchId, batchId)
        .where(FirestoreKeys.month, isEqualTo: monthKey)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(PaymentModel.fromSnapshot)
              .map((model) => model.toEntity())
              .where((payment) => payment.status != FirestoreKeys.statusVoided)
              .toList(),
        );
  }
}

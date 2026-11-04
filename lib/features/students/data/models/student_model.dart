import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:feemanager/features/students/domain/entities/student_draft.dart';
import 'package:feemanager/features/students/domain/entities/student_payment_summary.dart';

/// Maps student Firestore documents.
class StudentModel {
  /// Creates a student model.
  StudentModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.dateOfBirth,
    required this.age,
    required this.guardianName,
    required this.guardianPhone,
    required this.address,
    required this.monthlyFee,
    required this.isActive,
    required this.createdAt,
  });

  /// Builds from a snapshot.
  factory StudentModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final dob = data[FirestoreKeys.dateOfBirth];
    return StudentModel(
      id: snapshot.id,
      fullName: data[FirestoreKeys.fullName] as String? ?? '',
      phoneNumber: data[FirestoreKeys.phoneNumber] as String?,
      whatsappNumber: data[FirestoreKeys.whatsappNumber] as String? ?? '',
      dateOfBirth: dob is Timestamp ? dob.toDate() : null,
      age: (data[FirestoreKeys.age] as num?)?.toInt(),
      guardianName: data[FirestoreKeys.guardianName] as String?,
      guardianPhone: data[FirestoreKeys.guardianPhone] as String?,
      address: data[FirestoreKeys.address] as String?,
      monthlyFee: (data[FirestoreKeys.monthlyFee] as num?)?.toInt() ?? 0,
      isActive: data[FirestoreKeys.isActive] as bool? ?? true,
      createdAt:
          (data[FirestoreKeys.createdAt] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Document id.
  final String id;

  /// Full name field.
  final String fullName;

  /// Phone field.
  final String? phoneNumber;

  /// WhatsApp field.
  final String whatsappNumber;

  /// Date of birth field.
  final DateTime? dateOfBirth;

  /// Age field.
  final int? age;

  /// Guardian name field.
  final String? guardianName;

  /// Guardian phone field.
  final String? guardianPhone;

  /// Address field.
  final String? address;

  /// Monthly fee field.
  final int monthlyFee;

  /// Active flag.
  final bool isActive;

  /// Created timestamp.
  final DateTime createdAt;

  /// Converts to a domain entity.
  Student toEntity() {
    return Student(
      id: id,
      fullName: fullName,
      phoneNumber: phoneNumber,
      whatsappNumber: whatsappNumber,
      dateOfBirth: dateOfBirth,
      age: age,
      guardianName: guardianName,
      guardianPhone: guardianPhone,
      address: address,
      monthlyFee: monthlyFee,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  /// Map for creating a new student document.
  static Map<String, Object?> createMap(StudentDraft draft) {
    return <String, Object?>{
      FirestoreKeys.fullName: draft.fullName.trim(),
      FirestoreKeys.phoneNumber: draft.phoneNumber,
      FirestoreKeys.whatsappNumber: draft.whatsappNumber,
      FirestoreKeys.dateOfBirth: draft.dateOfBirth == null
          ? null
          : Timestamp.fromDate(draft.dateOfBirth!),
      FirestoreKeys.age: draft.dateOfBirth == null ? draft.age : null,
      FirestoreKeys.guardianName: _nullableTrim(draft.guardianName),
      FirestoreKeys.guardianPhone: draft.guardianPhone,
      FirestoreKeys.address: _nullableTrim(draft.address),
      FirestoreKeys.monthlyFee: draft.monthlyFee,
      FirestoreKeys.isActive: true,
      FirestoreKeys.createdAt: FieldValue.serverTimestamp(),
    };
  }

  /// Map for updating an existing student.
  static Map<String, Object?> updateMap(StudentDraft draft) {
    return <String, Object?>{
      FirestoreKeys.fullName: draft.fullName.trim(),
      FirestoreKeys.phoneNumber: draft.phoneNumber,
      FirestoreKeys.whatsappNumber: draft.whatsappNumber,
      FirestoreKeys.dateOfBirth: draft.dateOfBirth == null
          ? null
          : Timestamp.fromDate(draft.dateOfBirth!),
      FirestoreKeys.age: draft.dateOfBirth == null ? draft.age : null,
      FirestoreKeys.guardianName: _nullableTrim(draft.guardianName),
      FirestoreKeys.guardianPhone: draft.guardianPhone,
      FirestoreKeys.address: _nullableTrim(draft.address),
      FirestoreKeys.monthlyFee: draft.monthlyFee,
    };
  }

  static String? _nullableTrim(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// Maps payment documents for student history.
class StudentPaymentModel {

  /// Creates a payment model.
  StudentPaymentModel({
    required this.id,
    required this.month,
    required this.amount,
    required this.mode,
    required this.receiptNo,
    required this.status,
    required this.receiptUrl,
    required this.receiptPath,
  });
  /// Builds from a snapshot.
  factory StudentPaymentModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return StudentPaymentModel(
      id: snapshot.id,
      month: data[FirestoreKeys.month] as String? ?? '',
      amount: (data[FirestoreKeys.amount] as num?)?.toInt() ?? 0,
      mode: data[FirestoreKeys.mode] as String? ?? '',
      receiptNo: data[FirestoreKeys.receiptNo] as String?,
      status: data[FirestoreKeys.status] as String? ?? '',
      receiptUrl: data[FirestoreKeys.receiptUrl] as String?,
      receiptPath: data[FirestoreKeys.receiptPath] as String?,
    );
  }

  /// Document id.
  final String id;

  /// Month key.
  final String month;

  /// Amount in rupees.
  final int amount;

  /// Mode value.
  final String mode;

  /// Receipt number.
  final String? receiptNo;

  /// Status value.
  final String status;

  /// Receipt URL.
  final String? receiptUrl;

  /// Storage path for the PDF.
  final String? receiptPath;

  /// Converts to domain summary.
  StudentPaymentSummary toEntity() {
    return StudentPaymentSummary(
      id: id,
      month: month,
      amount: amount,
      mode: mode,
      receiptNo: receiptNo,
      status: status,
      receiptUrl: receiptUrl,
      receiptPath: receiptPath,
    );
  }
}

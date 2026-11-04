import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/features/fees/domain/entities/payment.dart';

/// Maps payment Firestore documents.
class PaymentModel {
  /// Creates a payment model.
  PaymentModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.guardianName,
    required this.whatsappNumber,
    required this.month,
    required this.amount,
    required this.batchFee,
    required this.mode,
    required this.status,
    required this.receiptNo,
    required this.receiptUrl,
    required this.receiptPath,
    required this.sentAt,
    required this.paidOn,
  });

  /// Builds from a snapshot.
  factory PaymentModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final sentAt = data[FirestoreKeys.sentAt];
    final paidOn = data[FirestoreKeys.paidOn];
    return PaymentModel(
      id: snapshot.id,
      studentId: data[FirestoreKeys.studentId] as String? ?? '',
      studentName: data[FirestoreKeys.studentName] as String? ?? '',
      guardianName: data[FirestoreKeys.guardianName] as String?,
      whatsappNumber: data[FirestoreKeys.whatsappNumber] as String? ?? '',
      month: data[FirestoreKeys.month] as String? ?? '',
      amount: (data[FirestoreKeys.amount] as num?)?.toInt() ?? 0,
      batchFee: (data[FirestoreKeys.batchFee] as num?)?.toInt() ?? 0,
      mode: data[FirestoreKeys.mode] as String? ?? '',
      status: data[FirestoreKeys.status] as String? ?? '',
      receiptNo: data[FirestoreKeys.receiptNo] as String?,
      receiptUrl: data[FirestoreKeys.receiptUrl] as String?,
      receiptPath: data[FirestoreKeys.receiptPath] as String?,
      sentAt: sentAt is Timestamp ? sentAt.toDate() : null,
      paidOn: paidOn is Timestamp
          ? paidOn.toDate()
          : DateTime.now(),
    );
  }

  /// Document id.
  final String id;

  /// Student id field.
  final String studentId;

  /// Student name snapshot.
  final String studentName;

  /// Guardian snapshot.
  final String? guardianName;

  /// WhatsApp snapshot.
  final String whatsappNumber;

  /// Month key.
  final String month;

  /// Amount field.
  final int amount;

  /// Batch fee snapshot.
  final int batchFee;

  /// Mode field.
  final String mode;

  /// Status field.
  final String status;

  /// Receipt number.
  final String? receiptNo;

  /// Receipt URL.
  final String? receiptUrl;

  /// Storage path for the PDF.
  final String? receiptPath;

  /// Sent timestamp.
  final DateTime? sentAt;

  /// Paid date.
  final DateTime paidOn;

  /// Converts to domain entity.
  Payment toEntity() {
    return Payment(
      id: id,
      studentId: studentId,
      studentName: studentName,
      guardianName: guardianName,
      whatsappNumber: whatsappNumber,
      month: month,
      amount: amount,
      batchFee: batchFee,
      mode: mode,
      status: status,
      receiptNo: receiptNo,
      receiptUrl: receiptUrl,
      receiptPath: receiptPath,
      sentAt: sentAt,
      paidOn: paidOn,
    );
  }
}

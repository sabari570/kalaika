import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feemanager/core/constants/app_defaults.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/core/utils/firebase_user_scope.dart';
import 'package:feemanager/core/utils/payment_document_id.dart';
import 'package:feemanager/core/utils/receipt_number_utils.dart';
import 'package:feemanager/core/utils/summary_delta_utils.dart';
import 'package:feemanager/features/fees/data/services/receipt_pdf_builder.dart';
import 'package:feemanager/features/fees/domain/entities/institute_settings.dart';
import 'package:feemanager/features/fees/domain/entities/record_payment_result.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:intl/intl.dart';

/// Client-side payment writes and receipt PDF generation (Spark path).
class PaymentWriteDataSource {
  /// Creates the data source.
  PaymentWriteDataSource({
    FirebaseFirestore? firestore,
    Future<ReceiptPdfBuilder> Function()? pdfBuilderLoader,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _pdfBuilderLoader = pdfBuilderLoader ?? ReceiptPdfBuilder.instance;

  final FirebaseFirestore _firestore;
  final Future<ReceiptPdfBuilder> Function() _pdfBuilderLoader;

  /// Records payment, updates counter and summary, returns PDF bytes.
  Future<RecordPaymentResult> recordPaymentAndReceipt({
    required String branchId,
    required String batchId,
    required Student student,
    required String monthKey,
    required int amount,
    required String mode,
    required DateTime paidOn,
    String? note,
  }) async {
    final uid = FirebaseUserScope.requireUid();
    final paymentId = PaymentDocumentId.fromStudentAndMonth(
      student.id,
      monthKey,
    );
    final payRef = _paymentRef(uid, branchId, batchId, paymentId);
    final existing = await payRef.get();
    if (existing.exists) {
      final data = existing.data() ?? <String, dynamic>{};
      final voided = data[FirestoreKeys.voided] as bool? ?? false;
      if (!voided) {
        final context = await _loadReceiptContext(
          uid: uid,
          branchId: branchId,
          batchId: batchId,
          student: student,
        );
        if (context == null) {
          throw StateError(AppStrings.receiptGenerateFailed);
        }
        final pdf = await _buildPdfFromPaymentMap(
          data: data,
          context: context,
          monthKey: monthKey,
          note: note,
        );
        return RecordPaymentResult(
          receiptNo: data[FirestoreKeys.receiptNo] as String? ?? '',
          status: data[FirestoreKeys.status] as String? ??
              FirestoreKeys.statusPaid,
          pdfBytes: pdf,
        );
      }
    }

    final context = await _loadReceiptContext(
      uid: uid,
      branchId: branchId,
      batchId: batchId,
      student: student,
    );
    if (context == null) {
      throw StateError(AppStrings.unknownError);
    }

    final year = int.parse(monthKey.substring(0, 4));
    final counterRef = _countersRef(uid);
    var receiptNo = '';

    await _firestore.runTransaction((transaction) async {
      final counterSnap = await transaction.get(counterRef);
      final currentSeq =
          (counterSnap.data()?[FirestoreKeys.receiptSeq] as num?)?.toInt() ??
          0;
      final nextSeq = currentSeq + 1;
      receiptNo = ReceiptNumberUtils.format(year, nextSeq);

      if (counterSnap.exists) {
        transaction.update(counterRef, {
          FirestoreKeys.receiptSeq: nextSeq,
        });
      } else {
        transaction.set(counterRef, {
          FirestoreKeys.receiptSeq: nextSeq,
        });
      }

      final paymentData = _paymentPayload(
        uid: uid,
        branchId: branchId,
        batchId: batchId,
        student: student,
        batchFee: context.batchDefaultFee,
        monthKey: monthKey,
        amount: amount,
        mode: mode,
        paidOn: paidOn,
        note: note,
        receiptNo: receiptNo,
      );

      transaction.set(payRef, paymentData);

      final afterSnapshot = PaymentSummarySnapshot.fromMap(paymentData);
      final delta = SummaryDeltaUtils.deltaSummary(null, afterSnapshot);
      final summaryUpdate = SummaryDeltaUtils.buildSummaryUpdate(
        monthKey: monthKey,
        batchId: batchId,
        branchId: branchId,
        delta: delta,
      );
      if (summaryUpdate.isNotEmpty) {
        final summaryRef = _summaryRef(uid, monthKey);
        transaction.set(summaryRef, summaryUpdate, SetOptions(merge: true));
      }
    });

    final pdfInput = _pdfInput(
      context: context,
      receiptNo: receiptNo,
      monthKey: monthKey,
      mode: mode,
      amount: amount,
      paidOn: paidOn,
      note: note,
      student: student,
    );
    final builder = await _pdfBuilderLoader();
    final pdfBytes = await builder.build(pdfInput);

    return RecordPaymentResult(
      receiptNo: receiptNo,
      status: FirestoreKeys.statusPaid,
      pdfBytes: pdfBytes,
    );
  }

  /// Builds PDF bytes for an existing payment document.
  Future<Uint8List> buildReceiptPdf({
    required String branchId,
    required String batchId,
    required String paymentId,
    required Student student,
  }) async {
    final uid = FirebaseUserScope.requireUid();
    final snap = await _paymentRef(uid, branchId, batchId, paymentId).get();
    if (!snap.exists) {
      throw StateError(AppStrings.receiptOpenFailed);
    }
    final data = snap.data() ?? <String, dynamic>{};
    final context = await _loadReceiptContext(
      uid: uid,
      branchId: branchId,
      batchId: batchId,
      student: student,
    );
    if (context == null) {
      throw StateError(AppStrings.receiptOpenFailed);
    }
    final monthKey = data[FirestoreKeys.month] as String? ?? '';
    return _buildPdfFromPaymentMap(
      data: data,
      context: context,
      monthKey: monthKey,
      note: data[FirestoreKeys.note] as String?,
    );
  }

  /// Marks a paid payment as sent and updates summaries.
  Future<void> markReceiptSent({
    required String branchId,
    required String batchId,
    required String paymentId,
  }) async {
    final uid = FirebaseUserScope.requireUid();
    final payRef = _paymentRef(uid, branchId, batchId, paymentId);
    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(payRef);
      if (!snap.exists) {
        throw StateError(AppStrings.unknownError);
      }
      final beforeData = snap.data() ?? <String, dynamic>{};
      if (beforeData[FirestoreKeys.status] != FirestoreKeys.statusPaid) {
        return;
      }
      final before = PaymentSummarySnapshot.fromMap(beforeData);
      final afterData = Map<String, dynamic>.from(beforeData)
        ..[FirestoreKeys.status] = FirestoreKeys.statusSent
        ..[FirestoreKeys.sentVia] = 'share'
        ..[FirestoreKeys.sentAt] = FieldValue.serverTimestamp();
      transaction.update(payRef, {
        FirestoreKeys.status: FirestoreKeys.statusSent,
        FirestoreKeys.sentVia: 'share',
        FirestoreKeys.sentAt: FieldValue.serverTimestamp(),
      });
      final after = PaymentSummarySnapshot.fromMap(afterData);
      final delta = SummaryDeltaUtils.deltaSummary(before, after);
      final monthKey = before.month;
      final summaryUpdate = SummaryDeltaUtils.buildSummaryUpdate(
        monthKey: monthKey,
        batchId: batchId,
        branchId: branchId,
        delta: delta,
      );
      if (summaryUpdate.isNotEmpty) {
        transaction.set(
          _summaryRef(uid, monthKey),
          summaryUpdate,
          SetOptions(merge: true),
        );
      }
    });
  }

  /// Voids a payment and reverses summary rollups.
  Future<void> voidPayment({
    required String branchId,
    required String batchId,
    required String paymentId,
  }) async {
    final uid = FirebaseUserScope.requireUid();
    final payRef = _paymentRef(uid, branchId, batchId, paymentId);
    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(payRef);
      if (!snap.exists) {
        throw StateError(AppStrings.unknownError);
      }
      final beforeData = snap.data() ?? <String, dynamic>{};
      if (beforeData[FirestoreKeys.voided] == true) {
        return;
      }
      final before = PaymentSummarySnapshot.fromMap(beforeData);
      final afterData = Map<String, dynamic>.from(beforeData)
        ..[FirestoreKeys.voided] = true
        ..[FirestoreKeys.status] = FirestoreKeys.statusVoided;
      transaction.update(payRef, {
        FirestoreKeys.voided: true,
        FirestoreKeys.status: FirestoreKeys.statusVoided,
      });
      final after = PaymentSummarySnapshot.fromMap(afterData);
      final delta = SummaryDeltaUtils.deltaSummary(before, after);
      final monthKey = before.month;
      final summaryUpdate = SummaryDeltaUtils.buildSummaryUpdate(
        monthKey: monthKey,
        batchId: batchId,
        branchId: branchId,
        delta: delta,
      );
      if (summaryUpdate.isNotEmpty) {
        transaction.set(
          _summaryRef(uid, monthKey),
          summaryUpdate,
          SetOptions(merge: true),
        );
      }
    });
  }

  Future<Uint8List> _buildPdfFromPaymentMap({
    required Map<String, dynamic> data,
    required _ReceiptContext context,
    required String monthKey,
    String? note,
  }) async {
    final paidOnRaw = data[FirestoreKeys.paidOn];
    final paidOn = paidOnRaw is Timestamp
        ? paidOnRaw.toDate()
        : DateTime.now();
    final receiptNo = data[FirestoreKeys.receiptNo] as String? ?? '';
    final mode = data[FirestoreKeys.mode] as String? ?? '';
    final amount = (data[FirestoreKeys.amount] as num?)?.toInt() ?? 0;
    final effectiveNote = note ?? data[FirestoreKeys.note] as String?;
    final pdfInput = _pdfInput(
      context: context,
      receiptNo: receiptNo,
      monthKey: monthKey,
      mode: mode,
      amount: amount,
      paidOn: paidOn,
      note: effectiveNote,
      student: context.student,
    );
    final builder = await _pdfBuilderLoader();
    return builder.build(pdfInput);
  }

  ReceiptPdfInput _pdfInput({
    required _ReceiptContext context,
    required String receiptNo,
    required String monthKey,
    required String mode,
    required int amount,
    required DateTime paidOn,
    required Student student,
    String? note,
  }) {
    final parts = monthKey.split('-');
    final yearPart = parts.isNotEmpty ? parts.first : '';
    final monthPart = parts.length > 1 ? parts[1] : '1';
    final monthDate = DateTime(
      int.parse(yearPart),
      int.parse(monthPart),
    );
    final monthLabel = DateFormat('MMMM').format(monthDate);
    final guardian = student.guardianName?.trim() ?? '';
    final receivedFrom =
        guardian.isNotEmpty ? guardian : student.fullName;

    return ReceiptPdfInput(
      instituteName: context.institute.name,
      tagline: context.institute.tagline,
      addressLines: context.institute.addressLines,
      phone: context.institute.phone,
      footerNote: context.institute.footerNote,
      signatory: context.institute.signatory,
      receiptNo: receiptNo,
      paidOn: paidOn,
      receivedFrom: receivedFrom,
      studentName: student.fullName,
      branchName: context.branchName,
      batchName: context.batchName,
      danceStyle: context.danceStyle,
      monthLabel: monthLabel,
      yearLabel: yearPart,
      mode: mode,
      amount: amount,
      note: note,
    );
  }

  Map<String, Object?> _paymentPayload({
    required String uid,
    required String branchId,
    required String batchId,
    required Student student,
    required int batchFee,
    required String monthKey,
    required int amount,
    required String mode,
    required DateTime paidOn,
    required String receiptNo,
    String? note,
  }) {
    return <String, Object?>{
      FirestoreKeys.ownerId: uid,
      FirestoreKeys.branchId: branchId,
      FirestoreKeys.batchId: batchId,
      FirestoreKeys.studentId: student.id,
      FirestoreKeys.studentName: student.fullName,
      FirestoreKeys.guardianName: student.guardianName,
      FirestoreKeys.whatsappNumber: student.whatsappNumber,
      FirestoreKeys.month: monthKey,
      FirestoreKeys.amount: amount,
      FirestoreKeys.batchFee: batchFee,
      FirestoreKeys.mode: mode,
      FirestoreKeys.paidOn: Timestamp.fromDate(paidOn),
      FirestoreKeys.note: note,
      FirestoreKeys.status: FirestoreKeys.statusPaid,
      FirestoreKeys.receiptNo: receiptNo,
      FirestoreKeys.receiptPath: '',
      FirestoreKeys.receiptUrl: '',
      FirestoreKeys.sentAt: null,
      FirestoreKeys.sentVia: null,
      FirestoreKeys.voided: false,
      FirestoreKeys.createdAt: FieldValue.serverTimestamp(),
    };
  }

  Future<_ReceiptContext?> _loadReceiptContext({
    required String uid,
    required String branchId,
    required String batchId,
    required Student student,
  }) async {
    final userSnap = await _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .get();
    final branchSnap = await _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.branches)
        .doc(branchId)
        .get();
    final batchSnap = await _batchesRef(uid, branchId).doc(batchId).get();

    if (!userSnap.exists || !branchSnap.exists || !batchSnap.exists) {
      return null;
    }

    final institute = _readInstitute(userSnap.data());
    final branch = branchSnap.data() ?? <String, dynamic>{};
    final batch = batchSnap.data() ?? <String, dynamic>{};

    return _ReceiptContext(
      institute: institute,
      branchName: branch[FirestoreKeys.name] as String? ?? '',
      batchName: batch[FirestoreKeys.name] as String? ?? '',
      danceStyle: batch[FirestoreKeys.danceStyle] as String? ?? '',
      batchDefaultFee:
          (batch[FirestoreKeys.defaultFee] as num?)?.toInt() ?? 0,
      student: student,
    );
  }

  InstituteSettings _readInstitute(Map<String, dynamic>? userData) {
    final instituteRaw =
        userData?[FirestoreKeys.institute] as Map<String, dynamic>?;
    final institute = instituteRaw ?? <String, dynamic>{};
    final addressRaw = institute[FirestoreKeys.addressLines];
    final addressLines = addressRaw is List
        ? addressRaw.map((line) => line.toString()).toList()
        : <String>[];
    return InstituteSettings(
      name: institute[FirestoreKeys.name] as String? ??
          AppDefaults.instituteName,
      tagline: institute[FirestoreKeys.tagline] as String? ??
          AppDefaults.instituteTagline,
      addressLines: addressLines,
      phone: institute[FirestoreKeys.phone] as String? ??
          AppDefaults.institutePhone,
      footerNote: institute[FirestoreKeys.footerNote] as String? ?? '',
      signatory: institute[FirestoreKeys.signatory] as String? ?? '',
    );
  }

  DocumentReference<Map<String, dynamic>> _countersRef(String uid) {
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.meta)
        .doc(FirestoreKeys.counters);
  }

  DocumentReference<Map<String, dynamic>> _summaryRef(
    String uid,
    String monthKey,
  ) {
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(uid)
        .collection(FirestoreKeys.summaries)
        .doc(monthKey);
  }

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

  DocumentReference<Map<String, dynamic>> _paymentRef(
    String uid,
    String branchId,
    String batchId,
    String paymentId,
  ) {
    return _batchesRef(uid, branchId)
        .doc(batchId)
        .collection(FirestoreKeys.payments)
        .doc(paymentId);
  }
}

class _ReceiptContext {
  const _ReceiptContext({
    required this.institute,
    required this.branchName,
    required this.batchName,
    required this.danceStyle,
    required this.batchDefaultFee,
    required this.student,
  });

  final InstituteSettings institute;
  final String branchName;
  final String batchName;
  final String danceStyle;
  final int batchDefaultFee;
  final Student student;
}

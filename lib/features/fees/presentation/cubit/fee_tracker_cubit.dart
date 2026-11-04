import 'dart:async';
import 'dart:typed_data';

import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/core/error/failure.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/session/fee_month_session.dart';
import 'package:feemanager/core/utils/month_key_utils.dart';
import 'package:feemanager/core/utils/payment_document_id.dart';
import 'package:feemanager/features/fees/domain/entities/fee_row.dart';
import 'package:feemanager/features/fees/domain/entities/payment.dart';
import 'package:feemanager/features/fees/domain/entities/record_payment_result.dart';
import 'package:feemanager/features/fees/domain/usecases/payment_receipt_actions.dart';
import 'package:feemanager/features/fees/domain/usecases/record_payment_and_receipt.dart';
import 'package:feemanager/features/fees/domain/usecases/watch_monthly_fees.dart';
import 'package:feemanager/features/fees/presentation/cubit/fee_tracker_state.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Monthly fee list with dual Firestore listeners.
class FeeTrackerCubit extends Cubit<FeeTrackerState> {
  /// Creates the cubit.
  FeeTrackerCubit({
    required this._watchActiveStudents,
    required this._watchMonthlyPayments,
    required this._recordPaymentAndReceipt,
    required this._markReceiptSent,
    required this._buildReceiptPdf,
    required this._voidPayment,
  }) : super(const FeeTrackerLoading());

  final WatchActiveStudentsForFees _watchActiveStudents;
  final WatchMonthlyPayments _watchMonthlyPayments;
  final RecordPaymentAndReceipt _recordPaymentAndReceipt;
  final MarkReceiptSent _markReceiptSent;
  final BuildReceiptPdf _buildReceiptPdf;
  final VoidPayment _voidPayment;

  StreamSubscription<List<Student>>? _studentsSubscription;
  StreamSubscription<List<Payment>>? _paymentsSubscription;

  String? _branchId;
  String? _batchId;
  List<Student> _students = <Student>[];
  List<Payment> _payments = <Payment>[];
  DateTime _selectedMonth = FeeMonthSession.current();
  String _searchQuery = '';
  FeeListFilter _filter = FeeListFilter.all;
  var _recordingPayment = false;

  /// Starts listeners for the batch fee tab.
  void started({
    required String branchId,
    required String batchId,
  }) {
    final sameBatch = _branchId == branchId && _batchId == batchId;
    _branchId = branchId;
    _batchId = batchId;
    if (!sameBatch) {
      _selectedMonth = FeeMonthSession.current();
      _students = <Student>[];
      _payments = <Payment>[];
      _searchQuery = '';
      _filter = FeeListFilter.all;
      emit(const FeeTrackerLoading());
    }
    attachListeners();
  }

  /// Cancels Firestore listeners while keeping in-memory state.
  void detachListeners() {
    unawaited(_studentsSubscription?.cancel());
    unawaited(_paymentsSubscription?.cancel());
    _studentsSubscription = null;
    _paymentsSubscription = null;
  }

  /// Attaches the two fee tracker listeners.
  void attachListeners() {
    final branchId = _branchId;
    final batchId = _batchId;
    if (branchId == null || batchId == null) {
      return;
    }
    if (_studentsSubscription != null) {
      return;
    }
    _studentsSubscription = _watchActiveStudents(
      WatchFeesParams(branchId: branchId, batchId: batchId),
    ).listen(
      (students) {
        _students = students;
        _emitCombined();
      },
      onError: (_) => emit(const FeeTrackerFailure(AppStrings.unknownError)),
    );
    _listenPayments();
  }

  /// Updates the selected month and swaps the payments listener only.
  void monthChanged(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    FeeMonthSession.save(_selectedMonth);
    _listenPayments();
  }

  void searchChanged(String query) {
    _searchQuery = query.trim().toLowerCase();
    _emitCombined();
  }

  void filterChanged(FeeListFilter filter) {
    _filter = filter;
    _emitCombined();
  }

  /// Records payment, updates Firestore, and returns PDF bytes.
  Future<Result<RecordPaymentResult>> recordPayment({
    required FeeRow row,
    required String mode,
    required DateTime paidOn,
    String? note,
  }) async {
    if (_recordingPayment) {
      return const Err<RecordPaymentResult>(
        ValidationFailure(AppStrings.unknownError),
      );
    }
    final branchId = _branchId;
    final batchId = _batchId;
    if (branchId == null || batchId == null) {
      return const Err<RecordPaymentResult>(
        ValidationFailure(AppStrings.unknownError),
      );
    }
    if (row.displayStatus != FeeRowStatus.unpaid) {
      return const Err<RecordPaymentResult>(
        ValidationFailure(AppStrings.unknownError),
      );
    }
    _recordingPayment = true;
    try {
      final monthKey = MonthKeyUtils.toMonthKey(_selectedMonth);
      return await _recordPaymentAndReceipt(
        RecordPaymentParams(
          branchId: branchId,
          batchId: batchId,
          student: row.student,
          monthKey: monthKey,
          amount: row.amount,
          mode: mode,
          paidOn: paidOn,
          note: note,
        ),
      );
    } finally {
      _recordingPayment = false;
    }
  }

  /// Builds PDF bytes for a pending or sent row.
  Future<Result<Uint8List>> buildReceiptPdfForRow(FeeRow row) async {
    final branchId = _branchId;
    final batchId = _batchId;
    if (branchId == null || batchId == null) {
      return const Err<Uint8List>(ValidationFailure(AppStrings.unknownError));
    }
    final monthKey = MonthKeyUtils.toMonthKey(_selectedMonth);
    final paymentId = row.payment?.id ??
        PaymentDocumentId.fromStudentAndMonth(row.student.id, monthKey);
    return _buildReceiptPdf(
      BuildReceiptPdfParams(
        branchId: branchId,
        batchId: batchId,
        paymentId: paymentId,
        student: row.student,
      ),
    );
  }

  /// Marks the row payment as sent after sharing.
  Future<Result<void>> markReceiptSentForRow(FeeRow row) async {
    final branchId = _branchId;
    final batchId = _batchId;
    if (branchId == null || batchId == null) {
      return const Err<void>(ValidationFailure(AppStrings.unknownError));
    }
    final monthKey = MonthKeyUtils.toMonthKey(_selectedMonth);
    final paymentId = PaymentDocumentId.fromStudentAndMonth(
      row.student.id,
      monthKey,
    );
    return _markReceiptSent(
      MarkReceiptSentParams(
        branchId: branchId,
        batchId: batchId,
        paymentId: paymentId,
      ),
    );
  }

  /// Voids a recorded payment for the selected month.
  Future<Result<void>> voidPaymentForRow(FeeRow row) async {
    final branchId = _branchId;
    final batchId = _batchId;
    if (branchId == null || batchId == null) {
      return const Err<void>(ValidationFailure(AppStrings.unknownError));
    }
    final monthKey = MonthKeyUtils.toMonthKey(_selectedMonth);
    final paymentId = PaymentDocumentId.fromStudentAndMonth(
      row.student.id,
      monthKey,
    );
    return _voidPayment(
      VoidPaymentParams(
        branchId: branchId,
        batchId: batchId,
        paymentId: paymentId,
      ),
    );
  }

  void _listenPayments() {
    final branchId = _branchId;
    final batchId = _batchId;
    if (branchId == null || batchId == null) {
      return;
    }
    final monthKey = MonthKeyUtils.toMonthKey(_selectedMonth);
    unawaited(_paymentsSubscription?.cancel());
    _paymentsSubscription = _watchMonthlyPayments(
      WatchMonthlyPaymentsParams(
        branchId: branchId,
        batchId: batchId,
        monthKey: monthKey,
      ),
    ).listen(
      (payments) {
        _payments = payments;
        _emitCombined();
      },
      onError: (_) => emit(const FeeTrackerFailure(AppStrings.unknownError)),
    );
  }

  void _emitCombined() {
    final paymentByStudent = <String, Payment>{
      for (final payment in _payments) payment.studentId: payment,
    };
    final rows = _students.map((student) {
      final payment = paymentByStudent[student.id];
      final status = _statusFor(payment);
      return FeeRow(
        student: student,
        payment: payment,
        displayStatus: status,
        amount: payment?.amount ?? student.monthlyFee,
      );
    }).toList();
    var paidCount = 0;
    var collected = 0;
    for (final row in rows) {
      if (row.displayStatus != FeeRowStatus.unpaid) {
        paidCount++;
        collected += row.amount;
      }
    }
    final filtered = _applyFilters(rows);
    emit(
      FeeTrackerLoaded(
        selectedMonth: _selectedMonth,
        rows: rows,
        filteredRows: filtered,
        paidCount: paidCount,
        totalCount: rows.length,
        collected: collected,
        searchQuery: _searchQuery,
        filter: _filter,
        monthKey: MonthKeyUtils.toMonthKey(_selectedMonth),
      ),
    );
  }

  List<FeeRow> _applyFilters(List<FeeRow> rows) {
    return rows.where((row) {
      if (_filter == FeeListFilter.unpaid &&
          row.displayStatus != FeeRowStatus.unpaid) {
        return false;
      }
      if (_filter == FeeListFilter.pendingSend &&
          row.displayStatus != FeeRowStatus.pendingSend) {
        return false;
      }
      if (_filter == FeeListFilter.sent &&
          row.displayStatus != FeeRowStatus.sent) {
        return false;
      }
      if (_searchQuery.isEmpty) {
        return true;
      }
      final name = row.student.fullName.toLowerCase();
      final guardian = row.student.guardianName?.toLowerCase() ?? '';
      return name.contains(_searchQuery) || guardian.contains(_searchQuery);
    }).toList();
  }

  FeeRowStatus _statusFor(Payment? payment) {
    if (payment == null) {
      return FeeRowStatus.unpaid;
    }
    return switch (payment.status) {
      FirestoreKeys.statusSent => FeeRowStatus.sent,
      FirestoreKeys.statusPaid => FeeRowStatus.pendingSend,
      _ => FeeRowStatus.unpaid,
    };
  }

  @override
  Future<void> close() {
    unawaited(_studentsSubscription?.cancel());
    unawaited(_paymentsSubscription?.cancel());
    return super.close();
  }
}

import 'dart:async';
import 'dart:typed_data';

import 'package:feemanager/core/constants/app_routes.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/utils/phone_utils.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/features/fees/domain/entities/fee_row.dart';
import 'package:feemanager/features/fees/presentation/cubit/fee_tracker_cubit.dart';
import 'package:feemanager/features/fees/presentation/utils/receipt_share_utils.dart';
import 'package:feemanager/features/fees/presentation/widgets/mark_receipt_sent_dialog.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Share flow, WhatsApp checks, and mark-sent prompt after delivery.
abstract final class ReceiptDeliveryUtils {
  /// Guardian name for receipts, or the student name when absent.
  static String recipientName(Student student) {
    final guardian = student.guardianName?.trim() ?? '';
    if (guardian.isNotEmpty) {
      return guardian;
    }
    return student.fullName;
  }

  /// Returns false when WhatsApp is missing or invalid; may show a dialog.
  static Future<bool> ensureWhatsappForShare(
    BuildContext context, {
    required String branchId,
    required String batchId,
    required Student student,
  }) async {
    final result = PhoneUtils.normalize(
      student.whatsappNumber,
      bulkImport: false,
    );
    if (result is PhoneNormalized) {
      return true;
    }
    if (!context.mounted) {
      return false;
    }
    final edit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: const Text(AppStrings.validWhatsappRequired),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.editStudent),
          ),
        ],
      ),
    );
    if (edit == true && context.mounted) {
      await context.push(
        AppRoutes.studentEditPath(branchId, batchId, student.id),
      );
    }
    return false;
  }

  /// Shares [pdfBytes] and prompts to mark sent when appropriate.
  static Future<void> sharePdfAndPromptMarkSent({
    required BuildContext context,
    required FeeRow row,
    required String branchId,
    required String batchId,
    required FeeTrackerCubit cubit,
    required Uint8List pdfBytes,
    required String receiptNo,
    required bool promptMarkSent,
    bool treatRowAsPending = false,
  }) async {
    final canShare = await ensureWhatsappForShare(
      context,
      branchId: branchId,
      batchId: batchId,
      student: row.student,
    );
    if (!canShare || !context.mounted) {
      return;
    }
    var leftApp = false;
    final shareObserver = _LifecycleObserver((state) {
      if (state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused) {
        leftApp = true;
      }
    });
    final binding = WidgetsBinding.instance..addObserver(shareObserver);
    try {
      await ReceiptShareUtils.sharePdf(
        pdfBytes: pdfBytes,
        receiptNo: receiptNo,
      );
    } finally {
      binding.removeObserver(shareObserver);
    }
    if (!context.mounted || !promptMarkSent) {
      return;
    }
    if (!treatRowAsPending &&
        row.displayStatus != FeeRowStatus.pendingSend) {
      return;
    }
    if (leftApp) {
      await _waitForResume();
    }
    if (!context.mounted) {
      return;
    }
    await _promptMarkSent(context, row: row, cubit: cubit);
  }

  static Future<void> _waitForResume() async {
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      return;
    }
    final completer = Completer<void>();
    final observer = _LifecycleObserver((state) {
      if (state == AppLifecycleState.resumed && !completer.isCompleted) {
        completer.complete();
      }
    });
    final binding = WidgetsBinding.instance..addObserver(observer);
    try {
      await completer.future;
    } finally {
      binding.removeObserver(observer);
    }
  }

  static Future<void> _promptMarkSent(
    BuildContext context, {
    required FeeRow row,
    required FeeTrackerCubit cubit,
  }) async {
    final name = recipientName(row.student);
    final marked = await MarkReceiptSentDialog.show(
      context,
      recipientName: name,
    );
    if (marked != true || !context.mounted) {
      return;
    }
    final markResult = await cubit.markReceiptSentForRow(row);
    if (!context.mounted) {
      return;
    }
    switch (markResult) {
      case Success<void>():
        break;
      case Err(:final failure):
        AppSnackBar.showError(context, failure.message);
    }
  }
}

class _LifecycleObserver with WidgetsBindingObserver {
  _LifecycleObserver(this._onChange);

  final void Function(AppLifecycleState state) _onChange;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _onChange(state);
  }
}

import 'dart:async';
import 'dart:typed_data';

import 'package:feemanager/core/constants/app_routes.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/utils/phone_utils.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/blocking_progress_dialog.dart';
import 'package:feemanager/features/fees/domain/entities/fee_row.dart';
import 'package:feemanager/features/fees/presentation/cubit/fee_tracker_cubit.dart';
import 'package:feemanager/features/fees/presentation/utils/receipt_share_utils.dart';
import 'package:feemanager/features/fees/presentation/widgets/mark_receipt_sent_dialog.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// PDF bytes, receipt number, and share message for delivery.
typedef ReceiptSharePayload = ({
  Uint8List pdfBytes,
  String receiptNo,
  String shareMessage,
});

/// Whether share UI opened and whether the app went to background.
typedef ReceiptShareLaunch = ({bool launched, bool leftApp});

/// Share flow and mark-sent prompt after delivery.
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

  /// Loads share content with a blocking dialog, opens the share sheet, then
  /// optionally prompts to mark sent.
  static Future<void> loadShareAndPromptMarkSent({
    required BuildContext context,
    required FeeRow row,
    required FeeTrackerCubit cubit,
    required Future<Result<ReceiptSharePayload>> Function() loadPayload,
    required bool promptMarkSent,
    bool treatRowAsPending = false,
  }) async {
    BlockingProgressDialog.show(
      context,
      message: AppStrings.preparingReceiptShare,
    );
    final payloadResult = await loadPayload();
    if (!context.mounted) {
      return;
    }
    switch (payloadResult) {
      case Err(:final failure):
        BlockingProgressDialog.hide(context);
        AppSnackBar.showError(context, failure.message);
      case Success(:final value):
        final delivery = await _deliverShare(
          context: context,
          student: row.student,
          pdfBytes: value.pdfBytes,
          receiptNo: value.receiptNo,
          shareMessage: value.shareMessage,
          dismissPreparingOverlay: true,
        );
        if (!context.mounted || !promptMarkSent) {
          return;
        }
        if (!treatRowAsPending &&
            row.displayStatus != FeeRowStatus.pendingSend) {
          return;
        }
        if (delivery.leftApp) {
          await _waitForResume();
        }
        if (!context.mounted) {
          return;
        }
        await _promptMarkSent(context, row: row, cubit: cubit);
    }
  }

  /// Opens the share sheet for known content; dismisses preparing dialog when
  /// the system sheet appears.
  static Future<void> sharePreparedAndPromptMarkSent({
    required BuildContext context,
    required FeeRow row,
    required FeeTrackerCubit cubit,
    required Uint8List pdfBytes,
    required String receiptNo,
    required String shareMessage,
    required bool promptMarkSent,
    bool treatRowAsPending = false,
    bool showPreparingDialog = false,
  }) async {
    if (showPreparingDialog) {
      BlockingProgressDialog.show(
        context,
        message: AppStrings.preparingReceiptShare,
      );
    }
    final delivery = await _deliverShare(
      context: context,
      student: row.student,
      pdfBytes: pdfBytes,
      receiptNo: receiptNo,
      shareMessage: shareMessage,
      dismissPreparingOverlay: showPreparingDialog,
    );
    if (!context.mounted || !promptMarkSent) {
      return;
    }
    if (!treatRowAsPending &&
        row.displayStatus != FeeRowStatus.pendingSend) {
      return;
    }
    if (delivery.leftApp) {
      await _waitForResume();
    }
    if (!context.mounted) {
      return;
    }
    await _promptMarkSent(context, row: row, cubit: cubit);
  }

  /// Loads share content with a blocking dialog, then opens the share sheet.
  static Future<void> loadAndOpenShareSheet({
    required BuildContext context,
    required Student student,
    required Future<Result<ReceiptSharePayload>> Function() loadPayload,
  }) async {
    BlockingProgressDialog.show(
      context,
      message: AppStrings.preparingReceiptShare,
    );
    final payloadResult = await loadPayload();
    if (!context.mounted) {
      return;
    }
    switch (payloadResult) {
      case Err(:final failure):
        BlockingProgressDialog.hide(context);
        AppSnackBar.showError(context, failure.message);
      case Success(:final value):
        await _deliverShare(
          context: context,
          student: student,
          pdfBytes: value.pdfBytes,
          receiptNo: value.receiptNo,
          shareMessage: value.shareMessage,
          dismissPreparingOverlay: true,
        );
    }
  }

  static Future<ReceiptShareLaunch> _deliverShare({
    required BuildContext context,
    required Student student,
    required Uint8List pdfBytes,
    required String receiptNo,
    required String shareMessage,
    required bool dismissPreparingOverlay,
  }) async {
    final whatsappDigits = PhoneUtils.whatsappDigitsForDirectShare(
      student.whatsappNumber,
    );
    if (whatsappDigits != null) {
      final direct = await _openWhatsAppShare(
        context: context,
        pdfBytes: pdfBytes,
        receiptNo: receiptNo,
        shareMessage: shareMessage,
        phoneDigits: whatsappDigits,
        dismissPreparingOverlay: dismissPreparingOverlay,
      );
      if (direct.launched) {
        return direct;
      }
    }
    if (!context.mounted) {
      return (launched: false, leftApp: false);
    }
    final picker = await _openWhatsAppPickerShare(
      context: context,
      pdfBytes: pdfBytes,
      receiptNo: receiptNo,
      shareMessage: shareMessage,
      dismissPreparingOverlay: BlockingProgressDialog.isVisible,
    );
    if (picker.launched) {
      return picker;
    }
    if (!context.mounted) {
      return (launched: false, leftApp: false);
    }
    return _openSystemShareSheet(
      context: context,
      pdfBytes: pdfBytes,
      receiptNo: receiptNo,
      shareMessage: shareMessage,
      dismissPreparingOverlay: BlockingProgressDialog.isVisible,
    );
  }

  static Future<ReceiptShareLaunch> _openWhatsAppShare({
    required BuildContext context,
    required Uint8List pdfBytes,
    required String receiptNo,
    required String shareMessage,
    required String phoneDigits,
    required bool dismissPreparingOverlay,
  }) async {
    var leftApp = false;
    var overlayDismissed = !dismissPreparingOverlay;

    void dismissOverlay() {
      if (overlayDismissed || !context.mounted) {
        return;
      }
      if (!BlockingProgressDialog.isVisible) {
        overlayDismissed = true;
        return;
      }
      overlayDismissed = true;
      BlockingProgressDialog.hide(context);
    }

    final shareObserver = _LifecycleObserver((state) {
      if (state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused) {
        leftApp = true;
        dismissOverlay();
      }
    });
    final binding = WidgetsBinding.instance..addObserver(shareObserver);
    try {
      final opened = await ReceiptShareUtils.sharePdfToWhatsApp(
        pdfBytes: pdfBytes,
        receiptNo: receiptNo,
        phoneDigits: phoneDigits,
        text: shareMessage,
      );
      if (!opened) {
        dismissOverlay();
        return (launched: false, leftApp: false);
      }
      await _allowLifecycleToPause(leftApp: () => leftApp = true);
    } finally {
      binding.removeObserver(shareObserver);
      dismissOverlay();
    }
    return (launched: true, leftApp: leftApp);
  }

  static Future<ReceiptShareLaunch> _openWhatsAppPickerShare({
    required BuildContext context,
    required Uint8List pdfBytes,
    required String receiptNo,
    required String shareMessage,
    required bool dismissPreparingOverlay,
  }) async {
    var leftApp = false;
    var overlayDismissed = !dismissPreparingOverlay;

    void dismissOverlay() {
      if (overlayDismissed || !context.mounted) {
        return;
      }
      if (!BlockingProgressDialog.isVisible) {
        overlayDismissed = true;
        return;
      }
      overlayDismissed = true;
      BlockingProgressDialog.hide(context);
    }

    final shareObserver = _LifecycleObserver((state) {
      if (state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused) {
        leftApp = true;
        dismissOverlay();
      }
    });
    final binding = WidgetsBinding.instance..addObserver(shareObserver);
    try {
      final opened = await ReceiptShareUtils.sharePdfViaWhatsAppPicker(
        pdfBytes: pdfBytes,
        receiptNo: receiptNo,
        text: shareMessage,
      );
      if (!opened) {
        dismissOverlay();
        return (launched: false, leftApp: false);
      }
      await _allowLifecycleToPause(leftApp: () => leftApp = true);
    } finally {
      binding.removeObserver(shareObserver);
      dismissOverlay();
    }
    return (launched: true, leftApp: leftApp);
  }

  static Future<ReceiptShareLaunch> _openSystemShareSheet({
    required BuildContext context,
    required Uint8List pdfBytes,
    required String receiptNo,
    required String shareMessage,
    required bool dismissPreparingOverlay,
  }) async {
    var leftApp = false;
    var overlayDismissed = !dismissPreparingOverlay;

    void dismissOverlay() {
      if (overlayDismissed || !context.mounted) {
        return;
      }
      if (!BlockingProgressDialog.isVisible) {
        overlayDismissed = true;
        return;
      }
      overlayDismissed = true;
      BlockingProgressDialog.hide(context);
    }

    final shareObserver = _LifecycleObserver((state) {
      if (state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused) {
        leftApp = true;
        dismissOverlay();
      }
    });
    final binding = WidgetsBinding.instance..addObserver(shareObserver);
    try {
      await ReceiptShareUtils.sharePdf(
        pdfBytes: pdfBytes,
        receiptNo: receiptNo,
        text: shareMessage,
      );
      await _allowLifecycleToPause(leftApp: () => leftApp = true);
    } finally {
      binding.removeObserver(shareObserver);
      dismissOverlay();
    }
    return (launched: true, leftApp: leftApp);
  }

  static Future<void> _allowLifecycleToPause({
    required void Function() leftApp,
  }) async {
    if (WidgetsBinding.instance.lifecycleState ==
            AppLifecycleState.inactive ||
        WidgetsBinding.instance.lifecycleState ==
            AppLifecycleState.paused) {
      leftApp();
      return;
    }
    final completer = Completer<void>();
    final observer = _LifecycleObserver((state) {
      if (state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused) {
        leftApp();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
    final binding = WidgetsBinding.instance..addObserver(observer);
    try {
      await completer.future.timeout(
        const Duration(milliseconds: 400),
        onTimeout: () {},
      );
    } finally {
      binding.removeObserver(observer);
    }
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

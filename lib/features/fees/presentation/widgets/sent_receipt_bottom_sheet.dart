import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/gradient_button.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:feemanager/features/fees/domain/entities/fee_row.dart';
import 'package:feemanager/features/fees/presentation/cubit/fee_tracker_cubit.dart';
import 'package:feemanager/features/fees/presentation/utils/receipt_delivery_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Actions for a sent fee row (receipt details sheet).
class SentReceiptBottomSheet extends StatelessWidget {
  /// Creates the sheet content.
  const SentReceiptBottomSheet({
    required this.row,
    required this.branchId,
    required this.batchId,
    required this.cubit,
    super.key,
  });

  /// Fee row with a sent payment.
  final FeeRow row;

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Fee tracker cubit for PDF generation.
  final FeeTrackerCubit cubit;

  /// Shows the bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required FeeRow row,
    required String branchId,
    required String batchId,
    required FeeTrackerCubit cubit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SentReceiptBottomSheet(
        row: row,
        branchId: branchId,
        batchId: batchId,
        cubit: cubit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payment = row.payment;
    if (payment == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context).textTheme;
    final paidOnLabel = DateFormat.yMMMd().format(payment.paidOn);
    final sentLabel = payment.sentAt == null
        ? AppStrings.statusSent
        : DateFormat.yMMMd().format(payment.sentAt!);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(AppStrings.receiptDetails, style: theme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Text(
            row.student.fullName,
            style: theme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Receipt ${payment.receiptNo}'),
          Text('Rs. ${payment.amount} · ${payment.mode}'),
          Text('${AppStrings.paidOnDate}: $paidOnLabel'),
          Text('${AppStrings.statusSent}: $sentLabel'),
          const SizedBox(height: AppSpacing.lg),
          OutlinedCopperButton(
            label: AppStrings.openReceipt,
            onPressed: () => _shareReceipt(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          GradientButton(
            label: AppStrings.resendOnWhatsapp,
            onPressed: () => _shareReceipt(context),
          ),
        ],
      ),
    );
  }

  Future<void> _shareReceipt(BuildContext context) async {
    Navigator.of(context).pop();
    final pdfResult = await cubit.buildReceiptPdfForRow(row);
    if (!context.mounted) {
      return;
    }
    switch (pdfResult) {
      case Success(:final value):
        await ReceiptDeliveryUtils.sharePdfAndPromptMarkSent(
          context: context,
          row: row,
          branchId: branchId,
          batchId: batchId,
          cubit: cubit,
          pdfBytes: value,
          receiptNo: row.payment?.receiptNo ?? 'receipt',
          promptMarkSent: false,
        );
      case Err(:final failure):
        AppSnackBar.showError(context, failure.message);
    }
  }
}

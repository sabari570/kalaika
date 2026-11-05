import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/core/widgets/gradient_button.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:feemanager/features/fees/domain/entities/fee_row.dart';
import 'package:feemanager/features/fees/presentation/cubit/fee_tracker_cubit.dart';
import 'package:feemanager/features/fees/presentation/utils/receipt_delivery_utils.dart';
import 'package:feemanager/features/settings/domain/entities/whatsapp_delivery_mode.dart';
import 'package:feemanager/features/settings/domain/usecases/get_whatsapp_delivery_mode.dart';
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
            onPressed: () => _openReceipt(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          GradientButton(
            label: AppStrings.resendOnWhatsapp,
            onPressed: () => _resendOnWhatsApp(context),
          ),
        ],
      ),
    );
  }

  Future<WhatsAppDeliveryMode> _resolveDeliveryMode() async {
    final result = await sl<GetWhatsAppDeliveryMode>()(const NoParams());
    return switch (result) {
      Success(:final value) => value,
      Err() => WhatsAppDeliveryMode.defaultMode,
    };
  }

  Future<void> _openReceipt(BuildContext context) async {
    Navigator.of(context).pop();
    await ReceiptDeliveryUtils.loadAndOpenShareSheet(
      context: context,
      student: row.student,
      deliveryMode: WhatsAppDeliveryMode.receipt,
      loadPayload: () async {
        final pdfResult = await cubit.buildReceiptPdfForRow(row);
        return switch (pdfResult) {
          Success(:final value) => Success(
              (
                pdfBytes: value,
                receiptNo: row.payment?.receiptNo ?? 'receipt',
                shareMessage: '',
              ),
            ),
          Err(:final failure) => Err(failure),
        };
      },
    );
  }

  Future<void> _resendOnWhatsApp(BuildContext context) async {
    Navigator.of(context).pop();
    final deliveryMode = await _resolveDeliveryMode();
    if (!context.mounted) {
      return;
    }
    await ReceiptDeliveryUtils.loadAndOpenShareSheet(
      context: context,
      student: row.student,
      deliveryMode: deliveryMode,
      loadPayload: () => _loadSharePayload(deliveryMode),
    );
  }

  Future<Result<ReceiptSharePayload>> _loadSharePayload(
    WhatsAppDeliveryMode deliveryMode,
  ) async {
    final receiptNo = row.payment?.receiptNo ?? 'receipt';
    if (deliveryMode == WhatsAppDeliveryMode.message) {
      final messageResult = await cubit.buildShareMessageForRow(row);
      return switch (messageResult) {
        Success(:final value) => Success(
            (
              pdfBytes: null,
              receiptNo: receiptNo,
              shareMessage: value,
            ),
          ),
        Err(:final failure) => Err(failure),
      };
    }
    final pdfResult = await cubit.buildReceiptPdfForRow(row);
    return switch (pdfResult) {
      Success(:final value) => Success(
          (
            pdfBytes: value,
            receiptNo: receiptNo,
            shareMessage: '',
          ),
        ),
      Err(:final failure) => Err(failure),
    };
  }
}

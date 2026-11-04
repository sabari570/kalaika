import 'package:feemanager/core/constants/app_radius.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/theme/app_text_theme.dart';
import 'package:feemanager/core/widgets/gradient_button.dart';
import 'package:feemanager/core/widgets/ornamental_divider.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Confirmation before recording a monthly fee payment.
class RecordPaymentConfirmDialog extends StatelessWidget {
  /// Creates the dialog content.
  const RecordPaymentConfirmDialog({
    required this.studentName,
    required this.amount,
    required this.month,
    super.key,
  });

  /// Student full name.
  final String studentName;

  /// Fee amount in whole rupees.
  final int amount;

  /// Selected fee month.
  final DateTime month;

  /// Shows the dialog; returns true when the user confirms.
  static Future<bool?> show(
    BuildContext context, {
    required String studentName,
    required int amount,
    required DateTime month,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RecordPaymentConfirmDialog(
        studentName: studentName,
        amount: amount,
        month: month,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context).textTheme;
    final monthLabel = DateFormat('MMMM yyyy').format(
      DateTime(month.year, month.month),
    );
    final amountText = NumberFormat.decimalPattern().format(amount);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.copper.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.outline),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: colors.copper,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    AppStrings.recordPayment,
                    style: theme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const OrnamentalDivider(),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppStrings.recordPaymentConfirmIntro,
              style: theme.bodyLarge?.copyWith(color: colors.creamMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceHigh,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(color: colors.outline),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(studentName, style: theme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppStrings.recordPaymentAmountLine.replaceFirst(
                        '{amount}',
                        amountText,
                      ),
                      style: theme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppStrings.recordPaymentMonthLine.replaceFirst(
                        '{month}',
                        monthLabel,
                      ),
                      style: theme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppPalette.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(
                  color: AppPalette.error.withValues(alpha: 0.45),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.info_outline,
                      color: AppPalette.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        AppStrings.recordPaymentIrreversible,
                        style: GoogleFonts.poppins(
                          fontSize: AppTextTheme.bodySize,
                          height: 1.45,
                          color: colors.cream,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedCopperButton(
                    label: AppStrings.cancel,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: GradientButton(
                    label: AppStrings.confirmAndGenerateReceipt,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

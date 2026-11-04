import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/constants/payment_constants.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/widgets/gradient_button.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// User choices from the record payment sheet.
class RecordPaymentFormData {
  /// Creates form data.
  const RecordPaymentFormData({
    required this.mode,
    required this.paidOn,
  });

  /// Selected payment mode.
  final String mode;

  /// Date fee was received.
  final DateTime paidOn;
}

/// Confirmation before recording a monthly fee payment.
class RecordPaymentConfirmDialog extends StatefulWidget {
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

  /// Shows the dialog; returns form data when the user confirms.
  static Future<RecordPaymentFormData?> show(
    BuildContext context, {
    required String studentName,
    required int amount,
    required DateTime month,
  }) {
    return showDialog<RecordPaymentFormData>(
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
  State<RecordPaymentConfirmDialog> createState() =>
      _RecordPaymentConfirmDialogState();
}

class _RecordPaymentConfirmDialogState
    extends State<RecordPaymentConfirmDialog> {
  String _mode = PaymentConstants.modeCash;
  late DateTime _paidOn;

  @override
  void initState() {
    super.initState();
    _paidOn = DateTime.now();
  }

  Future<void> _pickPaidOn() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paidOn,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _paidOn = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context).textTheme;
    final monthLabel = DateFormat('MMMM yyyy').format(
      DateTime(widget.month.year, widget.month.month),
    );
    final amountText = NumberFormat.decimalPattern().format(widget.amount);
    final paidOnLabel = DateFormat.yMMMd().format(_paidOn);

    return Dialog(
      child: SingleChildScrollView(
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
              Text(AppStrings.recordPayment, style: theme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              Text(widget.studentName, style: theme.titleMedium),
              Text(
                AppStrings.recordPaymentAmountLine.replaceFirst(
                  '{amount}',
                  amountText,
                ),
              ),
              Text(
                AppStrings.recordPaymentMonthLine.replaceFirst(
                  '{month}',
                  monthLabel,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(AppStrings.paymentMode, style: theme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _mode,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(
                        value: PaymentConstants.modeCash,
                        child: Text('Cash'),
                      ),
                      DropdownMenuItem(
                        value: PaymentConstants.modeUpi,
                        child: Text('UPI'),
                      ),
                      DropdownMenuItem(
                        value: PaymentConstants.modeBank,
                        child: Text('Bank'),
                      ),
                      DropdownMenuItem(
                        value: PaymentConstants.modeOther,
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (selected) {
                      if (selected != null) {
                        setState(() => _mode = selected);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(AppStrings.paidOnDate, style: theme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: _pickPaidOn,
                child: Text(paidOnLabel),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppStrings.recordPaymentIrreversible,
                style: theme.bodySmall?.copyWith(color: colors.creamMuted),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedCopperButton(
                      label: AppStrings.cancel,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GradientButton(
                      label: AppStrings.confirmAndGenerateReceipt,
                      onPressed: () => Navigator.of(context).pop(
                        RecordPaymentFormData(
                          mode: _mode,
                          paidOn: _paidOn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

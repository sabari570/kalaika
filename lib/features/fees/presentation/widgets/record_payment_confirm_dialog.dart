import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/constants/payment_constants.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/widgets/app_text_field.dart';
import 'package:feemanager/core/widgets/gradient_button.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// User choices from the record payment sheet.
class RecordPaymentFormData {
  /// Creates form data.
  const RecordPaymentFormData({
    required this.amount,
    required this.mode,
    required this.paidOn,
    this.note,
  });

  /// Amount in whole rupees.
  final int amount;

  /// Selected payment mode.
  final String mode;

  /// Date fee was received.
  final DateTime paidOn;

  /// Optional note stored on the payment.
  final String? note;
}

/// Bottom sheet before recording a monthly fee payment.
class RecordPaymentConfirmSheet extends StatefulWidget {
  /// Creates the sheet content.
  const RecordPaymentConfirmSheet({
    required this.studentName,
    required this.amount,
    required this.batchDefaultFee,
    required this.month,
    super.key,
  });

  /// Student full name.
  final String studentName;

  /// Prefilled fee amount in whole rupees.
  final int amount;

  /// Batch default fee for helper text.
  final int batchDefaultFee;

  /// Selected fee month.
  final DateTime month;

  /// Shows the sheet; returns form data when the user confirms.
  static Future<RecordPaymentFormData?> show(
    BuildContext context, {
    required String studentName,
    required int amount,
    required int batchDefaultFee,
    required DateTime month,
  }) {
    return showModalBottomSheet<RecordPaymentFormData>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => RecordPaymentConfirmSheet(
        studentName: studentName,
        amount: amount,
        batchDefaultFee: batchDefaultFee,
        month: month,
      ),
    );
  }

  @override
  State<RecordPaymentConfirmSheet> createState() =>
      _RecordPaymentConfirmSheetState();
}

class _RecordPaymentConfirmSheetState extends State<RecordPaymentConfirmSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  String _mode = PaymentConstants.modeCash;
  late DateTime _paidOn;
  String? _amountError;

  static const List<(String mode, String label)> _modes =
      <(String, String)>[
    (PaymentConstants.modeCash, AppStrings.paymentModeCash),
    (PaymentConstants.modeUpi, AppStrings.paymentModeUpi),
    (PaymentConstants.modeBank, AppStrings.paymentModeBank),
    (PaymentConstants.modeOther, AppStrings.paymentModeOther),
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '${widget.amount}');
    _noteController = TextEditingController();
    _paidOn = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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

  void _confirm() {
    final parsed = int.tryParse(_amountController.text.trim());
    if (parsed == null || parsed <= 0) {
      setState(() => _amountError = AppStrings.studentFeeInvalid);
      return;
    }
    final note = _noteController.text.trim();
    Navigator.of(context).pop(
      RecordPaymentFormData(
        amount: parsed,
        mode: _mode,
        paidOn: _paidOn,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context).textTheme;
    final monthLabel = DateFormat('MMMM yyyy').format(
      DateTime(widget.month.year, widget.month.month),
    );
    final batchFeeText = NumberFormat.decimalPattern().format(
      widget.batchDefaultFee,
    );
    final paidOnLabel = DateFormat.yMMMd().format(_paidOn);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(AppStrings.recordPayment, style: theme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Text(widget.studentName, style: theme.titleMedium),
            Text(
              AppStrings.recordPaymentMonthLine.replaceFirst(
                '{month}',
                monthLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _amountController,
              label: AppStrings.recordPaymentAmountLabel,
              keyboardType: TextInputType.number,
              onChanged: (_) {
                if (_amountError != null) {
                  setState(() => _amountError = null);
                }
              },
            ),
            if (_amountError != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _amountError!,
                style: theme.bodySmall?.copyWith(color: AppPalette.error),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppStrings.recordPaymentBatchFeeLine.replaceFirst(
                '{amount}',
                batchFeeText,
              ),
              style: theme.bodySmall?.copyWith(color: colors.creamMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(AppStrings.paymentMode, style: theme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _modes.map((entry) {
                return FilterChip(
                  label: Text(entry.$2),
                  selected: _mode == entry.$1,
                  onSelected: (_) => setState(() => _mode = entry.$1),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(AppStrings.paidOnDate, style: theme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: _pickPaidOn,
              child: Text(paidOnLabel),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _noteController,
              label: AppStrings.paymentNoteOptional,
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppStrings.recordPaymentIrreversible,
              style: theme.bodySmall?.copyWith(color: colors.creamMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedCopperButton(
              label: AppStrings.cancel,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: AppSpacing.sm),
            GradientButton(
              label: AppStrings.confirmPayment,
              onPressed: _confirm,
            ),
          ],
        ),
      ),
    );
  }
}

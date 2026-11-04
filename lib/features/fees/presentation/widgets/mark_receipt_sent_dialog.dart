import 'package:feemanager/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

/// Asks whether the user sent the receipt via the share sheet.
class MarkReceiptSentDialog extends StatelessWidget {
  /// Creates the dialog.
  const MarkReceiptSentDialog({super.key});

  /// Shows the dialog; returns true when the user confirms send.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const MarkReceiptSentDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.markReceiptSentTitle),
      content: const Text(AppStrings.markReceiptSentMessage),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.markReceiptSentNo),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(AppStrings.markReceiptSentYes),
        ),
      ],
    );
  }
}

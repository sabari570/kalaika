import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/features/settings/domain/entities/whatsapp_delivery_mode.dart';
import 'package:flutter/material.dart';

/// Asks whether the user completed WhatsApp delivery.
class MarkReceiptSentDialog extends StatelessWidget {
  /// Creates the dialog.
  const MarkReceiptSentDialog({
    required this.recipientName,
    required this.deliveryMode,
    super.key,
  });

  /// Guardian or student name shown in the prompt.
  final String recipientName;

  /// Delivery mode that was used for this send.
  final WhatsAppDeliveryMode deliveryMode;

  /// Shows the dialog; returns true when the user confirms send.
  static Future<bool?> show(
    BuildContext context, {
    required String recipientName,
    WhatsAppDeliveryMode deliveryMode = WhatsAppDeliveryMode.receipt,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => MarkReceiptSentDialog(
        recipientName: recipientName,
        deliveryMode: deliveryMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMessage = deliveryMode == WhatsAppDeliveryMode.message;
    final title = isMessage
        ? AppStrings.markMessageSentTitle
        : AppStrings.markReceiptSentTitle;
    final bodyTemplate = isMessage
        ? AppStrings.markMessageSentMessage
        : AppStrings.markReceiptSentMessage;
    return AlertDialog(
      title: Text(title),
      content: Text(
        bodyTemplate.replaceFirst('{name}', recipientName),
      ),
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

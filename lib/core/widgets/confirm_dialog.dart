import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Standard confirmation dialog with formal actions.
class ConfirmDialog extends StatelessWidget {
  /// Creates a confirm dialog.
  const ConfirmDialog({
    required this.title,
    required this.message,
    this.confirmLabel = AppStrings.confirm,
    this.cancelLabel = AppStrings.cancel,
    this.isDestructive = false,
    super.key,
  });

  /// Dialog title.
  final String title;

  /// Dialog body text.
  final String message;

  /// Primary action label.
  final String confirmLabel;

  /// Dismiss action label.
  final String cancelLabel;

  /// Uses error styling when true.
  final bool isDestructive;

  /// Shows [ConfirmDialog] and returns true when confirmed.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = AppStrings.confirm,
    String cancelLabel = AppStrings.cancel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmLabel,
            style: TextStyle(
              color: isDestructive
                  ? Theme.of(context).colorScheme.error
                  : context.appColors.copper,
            ),
          ),
        ),
      ],
    );
  }
}

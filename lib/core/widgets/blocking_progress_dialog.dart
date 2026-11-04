import 'dart:async';

import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
import 'package:flutter/material.dart';

/// Non-dismissible dialog with a progress indicator and message.
abstract final class BlockingProgressDialog {
  static var _visible = false;

  /// Whether the blocking dialog is currently shown.
  static bool get isVisible => _visible;

  /// Shows the dialog using the root navigator.
  static void show(
    BuildContext context, {
    required String message,
  }) {
    if (_visible) {
      return;
    }
    _visible = true;
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: <Widget>[
                const KalaikaProgressIndicator(),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(dialogContext).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ).whenComplete(() {
        _visible = false;
      }),
    );
  }

  /// Closes the dialog when it is still open.
  static void hide(BuildContext context) {
    if (!_visible || !context.mounted) {
      return;
    }
    Navigator.of(context, rootNavigator: true).pop();
  }
}

import 'package:feemanager/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

/// Themed snack bar helper.
abstract final class AppSnackBar {
  /// Shows an error snack bar with [message].
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  /// Shows a generic failure snack bar.
  static void showUnknownError(BuildContext context) {
    showError(context, AppStrings.unknownError);
  }
}

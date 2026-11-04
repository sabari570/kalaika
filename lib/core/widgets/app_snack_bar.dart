import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/theme/app_text_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Root messenger so snack bars survive route changes from go_router.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Themed snack bar helper.
abstract final class AppSnackBar {
  static const Duration _displayDuration = Duration(seconds: 3);

  /// Shows a success snack bar with [message].
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      accent: AppPalette.success,
    );
  }

  /// Shows an error snack bar with [message].
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline,
      accent: AppPalette.error,
    );
  }

  /// Shows an error snack bar with a [actionLabel] that invokes [onAction].
  static void showErrorWithAction(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    final messenger = _messenger(context);
    if (messenger == null) {
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: _displayDuration,
          dismissDirection: DismissDirection.down,
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            0,
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
          ),
          content: _SnackBarContent(
            message: message,
            icon: Icons.error_outline,
            accent: AppPalette.error,
          ),
          action: SnackBarAction(
            label: actionLabel,
            onPressed: onAction,
          ),
        ),
      );
  }

  /// Shows a generic failure snack bar.
  static void showUnknownError(BuildContext context) {
    showError(context, AppStrings.unknownError);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color accent,
  }) {
    final messenger = _messenger(context);
    if (messenger == null) {
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: _displayDuration,
          dismissDirection: DismissDirection.down,
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            0,
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
          ),
          content: _SnackBarContent(
            message: message,
            icon: icon,
            accent: accent,
          ),
        ),
      );
  }

  static ScaffoldMessengerState? _messenger(BuildContext context) {
    return rootScaffoldMessengerKey.currentState ??
        ScaffoldMessenger.maybeOf(context);
  }
}

class _SnackBarContent extends StatelessWidget {
  const _SnackBarContent({
    required this.message,
    required this.icon,
    required this.accent,
  });

  final String message;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: <Widget>[
        Icon(icon, color: accent, size: 22),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: AppTextTheme.bodySize,
              fontWeight: FontWeight.w500,
              color: colors.cream,
            ),
          ),
        ),
      ],
    );
  }
}

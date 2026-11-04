import 'package:feemanager/core/constants/app_radius.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/theme/app_text_theme.dart';
import 'package:feemanager/core/widgets/gradient_button.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final theme = Theme.of(context).textTheme;

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
            Text(title, style: theme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: theme.bodyLarge),
            const SizedBox(height: AppSpacing.lg),
            OutlinedCopperButton(
              label: cancelLabel,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (isDestructive)
              _DestructiveConfirmButton(
                label: confirmLabel,
                onPressed: () => Navigator.of(context).pop(true),
              )
            else
              GradientButton(
                label: confirmLabel,
                onPressed: () => Navigator.of(context).pop(true),
              ),
          ],
        ),
      ),
    );
  }
}

class _DestructiveConfirmButton extends StatelessWidget {
  const _DestructiveConfirmButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: AppPalette.error),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: AppTextTheme.bodySize,
          fontWeight: FontWeight.w600,
          color: AppPalette.error,
        ),
      ),
    );
  }
}

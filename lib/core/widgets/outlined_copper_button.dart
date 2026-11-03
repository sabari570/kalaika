import 'package:feemanager/core/constants/app_radius.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/theme/app_text_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Secondary action with copper outline.
class OutlinedCopperButton extends StatelessWidget {
  /// Creates an outlined secondary button.
  const OutlinedCopperButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// Button label.
  final String label;

  /// Tap handler.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: colors.copper),
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
          color: colors.copper,
        ),
      ),
    );
  }
}

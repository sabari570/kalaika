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
    final enabled = onPressed != null;
    final borderColor =
        enabled ? colors.copper : colors.copper.withValues(alpha: 0.4);
    final labelColor =
        enabled ? colors.copper : colors.copper.withValues(alpha: 0.4);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: AppTextTheme.bodySize,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

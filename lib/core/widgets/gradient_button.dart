import 'package:feemanager/core/constants/app_radius.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/theme/app_text_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Primary action button with copper gradient fill.
class GradientButton extends StatelessWidget {
  /// Creates a gradient primary button.
  const GradientButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  /// Button label.
  final String label;

  /// Tap handler; ignored when [isLoading] is true.
  final VoidCallback? onPressed;

  /// Shows an indeterminate progress indicator when true.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onPressed != null && !isLoading;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.copperGlow,
            blurRadius: 24,
          ),
        ],
        gradient: enabled ? AppColors.goldGradient : null,
        color: enabled ? null : colors.copper.withValues(alpha: 0.4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onCopper,
                        ),
                      )
                    : Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: AppTextTheme.bodySize,
                          fontWeight: FontWeight.w600,
                          color: colors.onCopper,
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

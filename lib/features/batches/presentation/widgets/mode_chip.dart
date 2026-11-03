import 'package:feemanager/core/constants/app_radius.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/batch_constants.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/theme/app_text_theme.dart';
import 'package:feemanager/core/utils/batch_schedule_formatter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Compact label for a batch class mode.
class ModeChip extends StatelessWidget {
  /// Creates a chip for the stored [mode] value.
  const ModeChip({required this.mode, super.key});

  /// Stored mode value from the batch document.
  final String mode;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (Color bg, Color fg) = switch (mode) {
      BatchConstants.modeOnline => (
        colors.copper.withValues(alpha: 0.15),
        colors.copper,
      ),
      BatchConstants.modePrivate => (
        colors.surfaceHigh,
        colors.creamMuted,
      ),
      _ => (
        colors.success.withValues(alpha: 0.15),
        colors.success,
      ),
    };
    final label = BatchScheduleFormatter.modeLabel(mode);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: AppTextTheme.labelSize,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}

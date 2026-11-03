import 'package:feemanager/core/constants/app_durations.dart';
import 'package:feemanager/core/constants/app_radius.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/theme/app_text_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fee payment status for list rows and chips.
enum FeeDisplayStatus {
  /// No payment recorded for the month.
  unpaid,

  /// Paid but receipt not marked sent.
  pendingSend,

  /// Receipt marked sent.
  sent,
}

/// Compact status label for fee rows.
class StatusChip extends StatelessWidget {
  /// Creates a status chip for [status].
  const StatusChip({
    required this.status,
    this.sentLabel,
    super.key,
  });

  /// Current fee display status.
  final FeeDisplayStatus status;

  /// Optional override for sent state (for example date text).
  final String? sentLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (String label, Color bg, Color fg) = switch (status) {
      FeeDisplayStatus.unpaid => (
        AppStrings.statusUnpaid,
        colors.surfaceHigh,
        colors.creamMuted,
      ),
      FeeDisplayStatus.pendingSend => (
        AppStrings.statusPendingSend,
        colors.warning.withValues(alpha: 0.2),
        colors.warning,
      ),
      FeeDisplayStatus.sent => (
        sentLabel ?? AppStrings.statusSent,
        colors.success.withValues(alpha: 0.2),
        colors.success,
      ),
    };

    return AnimatedSwitcher(
      duration: AppDurations.chipSwitch,
      child: Container(
        key: ValueKey<String>(label),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: fg.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: AppTextTheme.labelSize,
            fontWeight: FontWeight.w500,
            color: fg,
          ),
        ),
      ),
    );
  }
}

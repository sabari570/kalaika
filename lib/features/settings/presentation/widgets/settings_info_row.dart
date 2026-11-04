import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/theme/app_text_theme.dart';
import 'package:flutter/material.dart';

/// Read-only label and value row for Settings cards.
class SettingsInfoRow extends StatelessWidget {
  /// Creates an info row.
  const SettingsInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  /// Leading icon.
  final IconData icon;

  /// Field label.
  final String label;

  /// Display value.
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceHigh,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(icon, size: 20, color: colors.copper),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.bodySmall?.copyWith(
                    color: colors.creamMuted,
                    fontSize: AppTextTheme.labelSize,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value.isEmpty ? '—' : value,
                  style: theme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

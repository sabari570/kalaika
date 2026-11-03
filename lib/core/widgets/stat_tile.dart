import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/theme/app_text_theme.dart';
import 'package:flutter/material.dart';

/// Summary metric with label and gold value.
class StatTile extends StatelessWidget {
  /// Creates a dashboard stat tile.
  const StatTile({
    required this.label,
    required this.value,
    this.icon,
    super.key,
  });

  /// Short label above the value.
  final String label;

  /// Primary metric text.
  final String value;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 18, color: colors.creamMuted),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Text(
                label,
                style: theme.labelMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: theme.headlineMedium?.copyWith(
            color: colors.gold,
            fontSize: AppTextTheme.headlineSize,
          ),
        ),
      ],
    );
  }
}

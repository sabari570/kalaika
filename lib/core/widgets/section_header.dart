import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/theme/app_text_theme.dart';
import 'package:flutter/material.dart';

/// Section title in Cinzel with optional trailing action.
class SectionHeader extends StatelessWidget {
  /// Creates a section header row.
  const SectionHeader({
    required this.title,
    this.trailing,
    super.key,
  });

  /// Section title text.
  final String title;

  /// Optional widget aligned to the trailing edge.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: theme.titleLarge?.copyWith(
                fontSize: AppTextTheme.titleSize,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

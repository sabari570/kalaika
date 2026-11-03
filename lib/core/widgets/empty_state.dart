import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Placeholder when a list or section has no data.
class EmptyState extends StatelessWidget {
  /// Creates an empty state with optional action.
  const EmptyState({
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Primary message.
  final String message;

  /// Icon above the message.
  final IconData icon;

  /// Optional action button label.
  final String? actionLabel;

  /// Invoked when the action button is pressed.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: colors.creamMuted),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.bodyLarge?.copyWith(color: colors.creamMuted),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:feemanager/core/constants/app_radius.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Surface card with optional tap ripple.
class KalaikaCard extends StatelessWidget {
  /// Creates a bordered surface card.
  const KalaikaCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    super.key,
  });

  /// Card content.
  final Widget child;

  /// Optional tap handler.
  final VoidCallback? onTap;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final content = Padding(padding: padding, child: child);

    return Material(
      color: AppPalette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: colors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(onTap: onTap, child: content),
    );
  }
}

import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Decorative divider with a centered diamond motif.
class OrnamentalDivider extends StatelessWidget {
  /// Creates a horizontal ornamental divider.
  const OrnamentalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Expanded(child: Divider(color: colors.divider, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  border: Border.all(color: colors.gold),
                  color: colors.surfaceHigh,
                ),
              ),
            ),
          ),
          Expanded(child: Divider(color: colors.divider, height: 1)),
        ],
      ),
    );
  }
}

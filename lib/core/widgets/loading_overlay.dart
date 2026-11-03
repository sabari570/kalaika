import 'package:feemanager/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Blocks interaction with a semi-transparent loading veil.
class LoadingOverlay extends StatelessWidget {
  /// Creates a loading overlay over [child].
  const LoadingOverlay({
    required this.isLoading,
    required this.child,
    super.key,
  });

  /// When true, shows the loading indicator.
  final bool isLoading;

  /// Content beneath the overlay.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Stack(
      children: <Widget>[
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: AppPalette.background.withValues(alpha: 0.6),
              child: Center(
                child: CircularProgressIndicator(color: colors.copper),
              ),
            ),
          ),
      ],
    );
  }
}

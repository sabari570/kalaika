import 'package:feemanager/core/constants/app_durations.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/theme/app_motion.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
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
    final fadeDuration = AppMotion.duration(
      context,
      AppDurations.overlayFade,
    );
    return Stack(
      children: <Widget>[
        child,
        if (isLoading)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: 1,
              duration: fadeDuration,
              child: ColoredBox(
                color: AppPalette.background.withValues(alpha: 0.6),
                child: const Center(
                  child: KalaikaProgressIndicator(
                    size: KalaikaProgressSize.large,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

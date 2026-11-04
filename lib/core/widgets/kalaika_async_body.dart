import 'package:feemanager/core/constants/app_durations.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/theme/app_motion.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
import 'package:flutter/material.dart';

/// Async presentation modes for list and detail screens.
enum KalaikaAsyncPhase {
  /// First load with no cached data.
  loading,

  /// Cached content visible while data refreshes.
  refreshing,

  /// Ready to interact.
  ready,
}

/// Switches between loading, refreshing overlay, and content.
class KalaikaAsyncBody extends StatelessWidget {
  /// Creates an async body.
  const KalaikaAsyncBody({
    required this.phase,
    required this.child,
    this.loadingPlaceholder,
    super.key,
  });

  /// Current async phase.
  final KalaikaAsyncPhase phase;

  /// Primary content when ready or refreshing.
  final Widget child;

  /// Optional skeleton or indicator for initial load.
  final Widget? loadingPlaceholder;

  @override
  Widget build(BuildContext context) {
    final switchDuration = AppMotion.duration(
      context,
      AppDurations.asyncSwitch,
    );

    if (phase == KalaikaAsyncPhase.loading) {
      return AnimatedSwitcher(
        duration: switchDuration,
        child: loadingPlaceholder ??
            const Center(
              key: ValueKey<String>('loading'),
              child: KalaikaProgressIndicator(
                size: KalaikaProgressSize.large,
              ),
            ),
      );
    }

    final colors = context.appColors;
    return Stack(
      children: <Widget>[
        AnimatedOpacity(
          duration: switchDuration,
          opacity: phase == KalaikaAsyncPhase.refreshing ? 0.55 : 1,
          child: IgnorePointer(
            ignoring: phase == KalaikaAsyncPhase.refreshing,
            child: child,
          ),
        ),
        if (phase == KalaikaAsyncPhase.refreshing)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(
              minHeight: 2,
              color: colors.copper,
              backgroundColor: colors.surfaceHigh,
            ),
          ),
      ],
    );
  }
}

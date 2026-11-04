import 'package:feemanager/core/constants/app_durations.dart';
import 'package:feemanager/core/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// Animates integer metrics and progress values smoothly.
class KalaikaAnimatedMetric extends StatelessWidget {
  /// Creates an animated metric builder.
  const KalaikaAnimatedMetric({
    required this.value,
    required this.builder,
    super.key,
  });

  /// Target numeric value.
  final double value;

  /// Builds UI from the tweened animated value.
  final Widget Function(BuildContext context, double animatedValue) builder;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.metricTween(context);
    if (duration == Duration.zero) {
      return builder(context, value);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: duration,
      curve: AppDurations.easeOut,
      builder: (context, animatedValue, child) {
        return builder(context, animatedValue);
      },
    );
  }
}

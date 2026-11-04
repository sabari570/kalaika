import 'package:feemanager/core/constants/app_durations.dart';
import 'package:flutter/material.dart';

/// Respects system reduced-motion settings for animations.
abstract final class AppMotion {
  /// Whether implicit animations should run.
  static bool enabled(BuildContext context) {
    return !MediaQuery.disableAnimationsOf(context);
  }

  /// Returns [duration] or zero when animations are disabled.
  static Duration duration(BuildContext context, Duration duration) {
    return enabled(context) ? duration : Duration.zero;
  }

  /// Standard list cross-fade duration.
  static Duration listCrossFade(BuildContext context) {
    return duration(context, AppDurations.listCrossFade);
  }

  /// Standard metric tween duration.
  static Duration metricTween(BuildContext context) {
    return duration(context, AppDurations.metricTween);
  }
}

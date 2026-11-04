import 'package:flutter/animation.dart';

/// Standard animation durations.
abstract final class AppDurations {
  /// Checkbox and status chip transitions.
  static const Duration chipSwitch = Duration(milliseconds: 150);

  /// Route fade-through transitions.
  static const Duration pageTransition = Duration(milliseconds: 225);

  /// Splash logo scale and fade.
  static const Duration splashLogo = Duration(milliseconds: 900);

  /// Splash subtitle delay before fade.
  static const Duration splashSubtitleDelay = Duration(milliseconds: 300);

  /// Minimum splash display before navigation.
  static const Duration splashMinimum = Duration(seconds: 2);

  /// Primary button loading indicator cycle.
  static const Duration buttonLoading = Duration(milliseconds: 300);

  /// List content cross-fade when month or filter context changes.
  static const Duration listCrossFade = Duration(milliseconds: 200);

  /// Summary numbers and progress bar tween.
  static const Duration metricTween = Duration(milliseconds: 200);

  /// Shimmer sweep cycle.
  static const Duration shimmer = Duration(milliseconds: 1400);

  /// Async body fade between loading and ready.
  static const Duration asyncSwitch = Duration(milliseconds: 200);

  /// Loading overlay fade.
  static const Duration overlayFade = Duration(milliseconds: 180);

  /// Default easing for entrance animations.
  static const Curve easeOut = Curves.easeOut;
}

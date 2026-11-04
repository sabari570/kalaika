import 'dart:async';

import 'package:feemanager/core/constants/app_durations.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Branded loading indicator sizes.
enum KalaikaProgressSize {
  /// Inline on buttons.
  small,

  /// Lists and dialogs.
  medium,

  /// Full-screen center.
  large,
}

/// Copper-themed indeterminate progress indicator.
class KalaikaProgressIndicator extends StatefulWidget {
  /// Creates a progress indicator.
  const KalaikaProgressIndicator({
    this.size = KalaikaProgressSize.medium,
    this.color,
    super.key,
  });

  /// Visual size preset.
  final KalaikaProgressSize size;

  /// Stroke color; defaults to theme copper.
  final Color? color;

  @override
  State<KalaikaProgressIndicator> createState() =>
      _KalaikaProgressIndicatorState();
}

class _KalaikaProgressIndicatorState extends State<KalaikaProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.buttonLoading,
    );
    unawaited(_controller.repeat());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _dimension => switch (widget.size) {
    KalaikaProgressSize.small => 22,
    KalaikaProgressSize.medium => 36,
    KalaikaProgressSize.large => 48,
  };

  double get _stroke => switch (widget.size) {
    KalaikaProgressSize.small => 2,
    KalaikaProgressSize.medium => 3,
    KalaikaProgressSize.large => 3.5,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = widget.color ?? colors.copper;
    final secondary = primary.withValues(alpha: 0.25);

    return SizedBox(
      width: _dimension,
      height: _dimension,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _DualArcPainter(
              progress: _controller.value,
              primary: primary,
              secondary: secondary,
              strokeWidth: _stroke,
            ),
          );
        },
      ),
    );
  }
}

class _DualArcPainter extends CustomPainter {
  _DualArcPainter({
    required this.progress,
    required this.primary,
    required this.secondary,
    required this.strokeWidth,
  });

  final double progress;
  final Color primary;
  final Color secondary;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final background = Paint()
      ..color = secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, background);

    final sweep = 2.4 + progress * 0.8;
    final start = progress * 6.28;
    final foreground = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(_DualArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

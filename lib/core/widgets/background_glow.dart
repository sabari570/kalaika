import 'package:feemanager/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Top-of-screen radial glow used on splash, login, and dashboard.
class BackgroundGlow extends StatelessWidget {
  /// Creates a full-screen background with optional [child].
  const BackgroundGlow({required this.child, super.key});

  /// Content painted above the glow.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppPalette.background,
        gradient: RadialGradient(
          center: Alignment(0, -0.85),
          radius: 1.2,
          colors: <Color>[
            AppPalette.backgroundGlow,
            AppPalette.background,
          ],
          stops: <double>[0, 0.65],
        ),
      ),
      child: child,
    );
  }
}

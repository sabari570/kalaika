import 'package:flutter/material.dart';

/// Consistent [SafeArea] wrapper for screen content.
class KalaikaScreenBody extends StatelessWidget {
  /// Creates a safe-area body wrapper.
  const KalaikaScreenBody({
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    super.key,
  });

  /// Content below the app bar or inside the shell.
  final Widget child;

  /// Inset top (status bar / notch).
  final bool top;

  /// Inset bottom (home indicator). Use false above bottom navigation.
  final bool bottom;

  /// Inset left.
  final bool left;

  /// Inset right.
  final bool right;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }
}

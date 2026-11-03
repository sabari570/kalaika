import 'package:flutter/material.dart';

/// Kalaika palette tokens from the product design system.
abstract final class AppPalette {
  /// Scaffold background.
  static const Color background = Color(0xFF07130C);

  /// Cards, sheets, and app bars.
  static const Color surface = Color(0xFF0E2116);

  /// Elevated cards, inputs, and selected rows.
  static const Color surfaceHigh = Color(0xFF14301F);

  /// Primary accent (copper).
  static const Color copper = Color(0xFFE07B2F);

  /// Highlight accent (gold).
  static const Color gold = Color(0xFFF0B35C);

  /// Gradient start for headings.
  static const Color goldLight = Color(0xFFF6D7A3);

  /// Gradient end and pressed states.
  static const Color copperDeep = Color(0xFFA9561E);

  /// Primary text on dark surfaces.
  static const Color cream = Color(0xFFF6E8D3);

  /// Secondary text and hints.
  static const Color creamMuted = Color(0xFFBDAE98);

  /// Text and icons on copper buttons.
  static const Color onCopper = Color(0xFF1A0E05);

  /// Receipt sent state.
  static const Color success = Color(0xFF5DBB86);

  /// Paid, receipt pending state.
  static const Color warning = Color(0xFFF2A93B);

  /// Errors and destructive actions.
  static const Color error = Color(0xFFE5645A);

  /// Subtle radial glow on key screens.
  static const Color backgroundGlow = Color(0x33123A22);

  /// Card and input border (copper at 30% opacity).
  static const Color outline = Color(0x4DE07B2F);

  /// Divider color (gold at 18% opacity).
  static const Color divider = Color(0x2EE8B36A);

  /// Primary button copper glow.
  static const Color copperGlow = Color(0x1AE07B2F);
}

/// Theme extension exposing Kalaika tokens beyond [ColorScheme].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Creates Kalaika color tokens.
  const AppColors({
    required this.surfaceHigh,
    required this.copper,
    required this.gold,
    required this.goldLight,
    required this.copperDeep,
    required this.cream,
    required this.creamMuted,
    required this.onCopper,
    required this.outline,
    required this.divider,
    required this.success,
    required this.warning,
    required this.copperGlow,
  });

  /// Elevated surface color.
  final Color surfaceHigh;

  /// Primary copper accent.
  final Color copper;

  /// Gold highlight.
  final Color gold;

  /// Gradient start (gold light).
  final Color goldLight;

  /// Gradient end (copper deep).
  final Color copperDeep;

  /// Primary readable text.
  final Color cream;

  /// Muted secondary text.
  final Color creamMuted;

  /// Text on copper-filled controls.
  final Color onCopper;

  /// Subtle copper border.
  final Color outline;

  /// Ornamental divider line.
  final Color divider;

  /// Success indicator.
  final Color success;

  /// Warning indicator.
  final Color warning;

  /// Soft glow behind primary buttons.
  final Color copperGlow;

  /// Default token set for the dark theme.
  static const AppColors dark = AppColors(
    surfaceHigh: AppPalette.surfaceHigh,
    copper: AppPalette.copper,
    gold: AppPalette.gold,
    goldLight: AppPalette.goldLight,
    copperDeep: AppPalette.copperDeep,
    cream: AppPalette.cream,
    creamMuted: AppPalette.creamMuted,
    onCopper: AppPalette.onCopper,
    outline: AppPalette.outline,
    divider: AppPalette.divider,
    success: AppPalette.success,
    warning: AppPalette.warning,
    copperGlow: AppPalette.copperGlow,
  );

  /// Linear gradient for headings and primary buttons.
  static LinearGradient get goldGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      AppPalette.goldLight,
      AppPalette.copper,
      AppPalette.copperDeep,
    ],
  );

  @override
  AppColors copyWith({
    Color? surfaceHigh,
    Color? copper,
    Color? gold,
    Color? goldLight,
    Color? copperDeep,
    Color? cream,
    Color? creamMuted,
    Color? onCopper,
    Color? outline,
    Color? divider,
    Color? success,
    Color? warning,
    Color? copperGlow,
  }) {
    return AppColors(
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      copper: copper ?? this.copper,
      gold: gold ?? this.gold,
      goldLight: goldLight ?? this.goldLight,
      copperDeep: copperDeep ?? this.copperDeep,
      cream: cream ?? this.cream,
      creamMuted: creamMuted ?? this.creamMuted,
      onCopper: onCopper ?? this.onCopper,
      outline: outline ?? this.outline,
      divider: divider ?? this.divider,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      copperGlow: copperGlow ?? this.copperGlow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      copper: Color.lerp(copper, other.copper, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldLight: Color.lerp(goldLight, other.goldLight, t)!,
      copperDeep: Color.lerp(copperDeep, other.copperDeep, t)!,
      cream: Color.lerp(cream, other.cream, t)!,
      creamMuted: Color.lerp(creamMuted, other.creamMuted, t)!,
      onCopper: Color.lerp(onCopper, other.onCopper, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      copperGlow: Color.lerp(copperGlow, other.copperGlow, t)!,
    );
  }
}

/// Convenience accessor for [AppColors] on [BuildContext].
extension AppColorsContext on BuildContext {
  /// Kalaika theme colors from the current [ThemeData].
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

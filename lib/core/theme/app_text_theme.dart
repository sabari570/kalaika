import 'package:feemanager/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the application [TextTheme] using bundled Google Fonts.
abstract final class AppTextTheme {
  /// Display size (32 sp).
  static const double displaySize = 32;

  /// Headline size (24 sp).
  static const double headlineSize = 24;

  /// Title size (18 sp).
  static const double titleSize = 18;

  /// Body size (14 sp).
  static const double bodySize = 14;

  /// Label size (12 sp).
  static const double labelSize = 12;

  /// Creates the dark theme text styles for Kalaika.
  static TextTheme dark(AppColors colors) {
    final base = GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );

    TextStyle cinzel({
      required double size,
      required FontWeight weight,
      required Color color,
      double? height,
      double letterSpacing = 0.6,
    }) {
      return GoogleFonts.cinzel(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    }

    TextStyle poppins({
      required double size,
      required FontWeight weight,
      required Color color,
      double? height,
      bool tabular = false,
    }) {
      return GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        fontFeatures: tabular
            ? const <FontFeature>[FontFeature.tabularFigures()]
            : null,
      );
    }

    return base.copyWith(
      displayLarge: cinzel(
        size: displaySize,
        weight: FontWeight.w700,
        color: colors.cream,
      ),
      headlineMedium: cinzel(
        size: headlineSize,
        weight: FontWeight.w600,
        color: colors.cream,
      ),
      titleLarge: cinzel(
        size: titleSize,
        weight: FontWeight.w600,
        color: colors.cream,
      ),
      titleMedium: poppins(
        size: titleSize,
        weight: FontWeight.w600,
        color: colors.cream,
      ),
      bodyLarge: poppins(
        size: bodySize,
        weight: FontWeight.w400,
        color: colors.cream,
      ),
      bodyMedium: poppins(
        size: bodySize,
        weight: FontWeight.w400,
        color: colors.cream,
        tabular: true,
      ),
      bodySmall: poppins(
        size: labelSize,
        weight: FontWeight.w400,
        color: colors.creamMuted,
      ),
      labelLarge: poppins(
        size: bodySize,
        weight: FontWeight.w600,
        color: colors.onCopper,
      ),
      labelMedium: poppins(
        size: labelSize,
        weight: FontWeight.w500,
        color: colors.creamMuted,
      ),
      labelSmall: poppins(
        size: labelSize,
        weight: FontWeight.w400,
        color: colors.creamMuted,
      ),
    );
  }
}

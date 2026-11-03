import 'package:feemanager/core/constants/app_radius.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/theme/app_text_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the single dark [ThemeData] for Phase 1.
abstract final class AppTheme {
  /// Dark Kalaika theme (Phase 1 only).
  static ThemeData dark() {
    const colors = AppColors.dark;
    final textTheme = AppTextTheme.dark(colors);
    final poppins = GoogleFonts.poppins();
    final colorScheme = ColorScheme.dark(
      surface: AppPalette.surface,
      onSurface: colors.cream,
      primary: colors.copper,
      onPrimary: colors.onCopper,
      secondary: colors.gold,
      onSecondary: colors.onCopper,
      error: AppPalette.error,
      onError: colors.cream,
      outline: colors.outline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppPalette.background,
      colorScheme: colorScheme,
      extensions: const <ThemeExtension<dynamic>>[colors],
      fontFamily: poppins.fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppPalette.surface,
        foregroundColor: colors.cream,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppPalette.surface,
        indicatorColor: colors.copper.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.poppins(
            fontSize: AppTextTheme.labelSize,
            fontWeight: FontWeight.w500,
            color: selected ? colors.gold : colors.creamMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colors.copper : colors.creamMuted,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: AppPalette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: colors.outline),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: colors.copper, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.creamMuted),
        labelStyle: textTheme.labelMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppPalette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: colors.outline),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceHigh,
        contentTextStyle: GoogleFonts.poppins(
          color: colors.cream,
          fontSize: AppTextTheme.bodySize,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: AppTextTheme.bodySize,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          fontSize: AppTextTheme.bodySize,
        ),
        indicatorColor: colors.copper,
        labelColor: colors.cream,
        unselectedLabelColor: colors.creamMuted,
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.copper,
        foregroundColor: colors.onCopper,
        elevation: 0,
      ),
    );
  }
}

import 'package:feemanager/core/constants/app_assets.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Which brand asset [KalaikaLogo] displays.
enum KalaikaLogoVariant {
  /// Full poster wordmark (`logo.png`).
  full,

  /// Emblem only (`logo_emblem.png`).
  emblem,
}

/// Brand mark from bundled assets or gradient wordmark fallback.
class KalaikaLogo extends StatelessWidget {
  /// Creates the logo at [size] logical pixels wide.
  const KalaikaLogo({
    this.size = 160,
    this.variant = KalaikaLogoVariant.full,
    super.key,
  });

  /// Maximum width of the logo area.
  final double size;

  /// Full wordmark or emblem-only artwork.
  final KalaikaLogoVariant variant;

  @override
  Widget build(BuildContext context) {
    final asset = switch (variant) {
      KalaikaLogoVariant.full => AppAssets.logo,
      KalaikaLogoVariant.emblem => AppAssets.logoEmblem,
    };

    return Semantics(
      label: AppStrings.appTitle,
      image: true,
      child: Image.asset(
        asset,
        width: size,
        height: variant == KalaikaLogoVariant.full ? size * 1.35 : size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          if (variant == KalaikaLogoVariant.emblem) {
            return _WordmarkFallback(size: size, compact: true);
          }
          return _WordmarkFallback(size: size, compact: false);
        },
      ),
    );
  }
}

class _WordmarkFallback extends StatelessWidget {
  const _WordmarkFallback({required this.size, required this.compact});

  final double size;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Icon(
        Icons.auto_awesome,
        size: size * 0.5,
        color: context.appColors.gold,
      );
    }

    final colors = context.appColors;
    return SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.goldGradient.createShader(bounds),
            child: Text(
              'KALAIKA',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: size * 0.18,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.taglineByLakshmi,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: size * 0.07,
              fontWeight: FontWeight.w400,
              color: colors.creamMuted,
            ),
          ),
        ],
      ),
    );
  }
}

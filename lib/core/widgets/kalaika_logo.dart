import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand mark from asset or gradient wordmark fallback.
class KalaikaLogo extends StatelessWidget {
  /// Creates the logo at [size] logical pixels wide.
  const KalaikaLogo({this.size = 160, super.key});

  /// Maximum width of the logo area.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _WordmarkFallback(size: size);
      },
    );
  }
}

class _WordmarkFallback extends StatelessWidget {
  const _WordmarkFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
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

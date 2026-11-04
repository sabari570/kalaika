import 'package:feemanager/core/constants/app_assets.dart';
import 'package:feemanager/core/constants/app_radius.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/theme/app_text_theme.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Branded white Google sign-in control for the login screen.
class GoogleSignInButton extends StatelessWidget {
  /// Creates the button.
  const GoogleSignInButton({
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  /// Tap handler; ignored when [isLoading] is true.
  final VoidCallback? onPressed;

  /// Shows a progress indicator when true.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return Material(
      color: AppPalette.googleButtonSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
        side: const BorderSide(color: AppPalette.googleButtonBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        splashColor: AppPalette.googleButtonLabel.withValues(alpha: 0.08),
        highlightColor: AppPalette.googleButtonLabel.withValues(alpha: 0.04),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: KalaikaProgressIndicator(
                        size: KalaikaProgressSize.small,
                        color: AppPalette.googleButtonLabel,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          AppAssets.googleIcon,
                          width: 22,
                          height: 22,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.g_mobiledata,
                            color: AppPalette.googleButtonLabel,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          AppStrings.signInWithGoogle,
                          style: GoogleFonts.poppins(
                            fontSize: AppTextTheme.bodySize,
                            fontWeight: FontWeight.w500,
                            color: AppPalette.googleButtonLabel,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

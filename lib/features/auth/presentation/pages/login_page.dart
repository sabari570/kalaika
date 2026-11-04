import 'dart:async';

import 'package:feemanager/core/constants/app_durations.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/theme/app_motion.dart';
import 'package:feemanager/core/theme/app_text_theme.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/background_glow.dart';
import 'package:feemanager/core/widgets/google_sign_in_button.dart';
import 'package:feemanager/core/widgets/kalaika_card.dart';
import 'package:feemanager/core/widgets/kalaika_logo.dart';
import 'package:feemanager/core/widgets/kalaika_screen_body.dart';
import 'package:feemanager/core/widgets/ornamental_divider.dart';
import 'package:feemanager/features/auth/presentation/cubit/login_cubit.dart';
import 'package:feemanager/features/auth/presentation/cubit/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Google sign-in screen.
class LoginPage extends StatefulWidget {
  /// Creates the login page.
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heroOpacity;
  late final Animation<Offset> _actionSlide;
  var _motionStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.splashLogo,
    );
    _heroOpacity = CurvedAnimation(
      parent: _controller,
      curve: AppDurations.easeOut,
    );
    _actionSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 1, curve: AppDurations.easeOut),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_motionStarted) {
      return;
    }
    _motionStarted = true;
    final duration = AppMotion.duration(context, AppDurations.splashLogo);
    _controller.duration = duration;
    if (duration == Duration.zero) {
      _controller.value = 1;
    } else {
      unawaited(_controller.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.appColors;

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          AppSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is LoginLoading;
        return BackgroundGlow(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: KalaikaScreenBody(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  children: <Widget>[
                    FadeTransition(
                      opacity: _heroOpacity,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: AppSpacing.xxl),
                          const KalaikaLogo(size: 120),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            AppStrings.signInTitle,
                            style: theme.titleLarge?.copyWith(
                              fontSize: AppTextTheme.headlineSize,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            AppStrings.signInSubtitle,
                            textAlign: TextAlign.center,
                            style: theme.bodyLarge?.copyWith(
                              color: colors.creamMuted,
                            ),
                          ),
                          const OrnamentalDivider(),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SlideTransition(
                      position: _actionSlide,
                      child: FadeTransition(
                        opacity: _heroOpacity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            KalaikaCard(
                              child: GoogleSignInButton(
                                isLoading: isLoading,
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        unawaited(
                                          context
                                              .read<LoginCubit>()
                                              .signInWithGoogle(),
                                        );
                                      },
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              AppStrings.signInPrivacyNote,
                              textAlign: TextAlign.center,
                              style: theme.bodySmall?.copyWith(
                                color: colors.creamMuted,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'dart:async';

import 'package:feemanager/core/constants/app_durations.dart';
import 'package:feemanager/core/constants/app_routes.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/widgets/background_glow.dart';
import 'package:feemanager/core/widgets/kalaika_logo.dart';
import 'package:feemanager/core/widgets/ornamental_divider.dart';
import 'package:feemanager/features/auth/presentation/cubit/splash_cubit.dart';
import 'package:feemanager/features/auth/presentation/cubit/splash_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Branded splash with initialization and auth timing.
class SplashPage extends StatefulWidget {
  /// Creates the splash page.
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _subtitleOpacity;

  @override
  void initState() {
    super.initState();
    final reduceMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    _controller = AnimationController(
      vsync: this,
      duration: reduceMotion
          ? Duration.zero
          : AppDurations.splashLogo,
    );
    _logoScale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppDurations.easeOut,
      ),
    );
    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: AppDurations.easeOut,
    );
    _subtitleOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.33,
        1,
        curve: AppDurations.easeOut,
      ),
    );
    if (reduceMotion) {
      _controller.value = 1;
    } else {
      unawaited(_controller.forward());
    }
    unawaited(context.read<SplashCubit>().started());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        switch (state) {
          case SplashReady(:final isAuthenticated):
            if (isAuthenticated) {
              context.go(AppRoutes.dashboard);
            } else {
              context.go(AppRoutes.login);
            }
          case SplashInitFailed():
            break;
          case SplashInitial():
            break;
        }
      },
      child: BackgroundGlow(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: BlocBuilder<SplashCubit, SplashState>(
                  builder: (context, state) {
                    if (state is SplashInitFailed) {
                      return Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      );
                    }
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const KalaikaLogo(size: 180),
                          const OrnamentalDivider(),
                          FadeTransition(
                            opacity: _subtitleOpacity,
                            child: Text(
                              AppStrings.feeManagement,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: context.appColors.creamMuted,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

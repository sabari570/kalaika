import 'dart:async';

import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_text_theme.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/background_glow.dart';
import 'package:feemanager/core/widgets/gradient_button.dart';
import 'package:feemanager/core/widgets/kalaika_logo.dart';
import 'package:feemanager/core/widgets/ornamental_divider.dart';
import 'package:feemanager/features/auth/presentation/cubit/login_cubit.dart';
import 'package:feemanager/features/auth/presentation/cubit/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Google sign-in screen.
class LoginPage extends StatelessWidget {
  /// Creates the login page.
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

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
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: AppSpacing.xxl),
                    const KalaikaLogo(size: 140),
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
                      style: theme.bodyLarge,
                    ),
                    const OrnamentalDivider(),
                    const Spacer(),
                    GradientButton(
                      label: AppStrings.continueWithGoogle,
                      isLoading: isLoading,
                      onPressed: isLoading
                          ? null
                          : () {
                              unawaited(
                                context.read<LoginCubit>().signInWithGoogle(),
                              );
                            },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
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

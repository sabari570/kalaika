import 'package:feemanager/core/constants/app_routes.dart';
import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Redirects routes based on the current authentication session.
String? authRedirect(BuildContext context, GoRouterState state) {
  if (kDebugMode && state.matchedLocation == AppRoutes.styleGuide) {
    return null;
  }

  final location = state.matchedLocation;
  final isLoggedIn = sl<AuthRepository>().currentUser != null;
  final isAuthRoute =
      location == AppRoutes.splash || location == AppRoutes.login;

  if (!isLoggedIn && !isAuthRoute) {
    return AppRoutes.login;
  }

  if (isLoggedIn && isAuthRoute) {
    return AppRoutes.dashboard;
  }

  return null;
}

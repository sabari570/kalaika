import 'package:feemanager/core/constants/app_durations.dart';
import 'package:feemanager/core/constants/app_routes.dart';
import 'package:feemanager/core/debug/style_guide_page.dart';
import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/core/router/auth_redirect.dart';
import 'package:feemanager/core/router/auth_refresh_listenable.dart';
import 'package:feemanager/core/router/home_shell_page.dart';
import 'package:feemanager/features/auth/presentation/cubit/login_cubit.dart';
import 'package:feemanager/features/auth/presentation/cubit/splash_cubit.dart';
import 'package:feemanager/features/auth/presentation/pages/login_page.dart';
import 'package:feemanager/features/auth/presentation/pages/splash_page.dart';
import 'package:feemanager/features/branches/presentation/pages/branches_placeholder_page.dart';
import 'package:feemanager/features/dashboard/presentation/pages/dashboard_placeholder_page.dart';
import 'package:feemanager/features/settings/presentation/pages/settings_placeholder_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Creates the application [GoRouter] instance.
GoRouter createAppRouter() {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final refreshListenable = sl<AuthRefreshListenable>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshListenable,
    redirect: authRedirect,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<SplashCubit>(),
            child: const SplashPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<LoginCubit>(),
            child: const LoginPage(),
          );
        },
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.styleGuide,
          builder: (context, state) => const StyleGuidePage(),
        ),
      GoRoute(
        path: AppRoutes.home,
        redirect: (context, state) => AppRoutes.dashboard,
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShellPage(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.dashboard,
                pageBuilder: (context, state) {
                  return _fadePage(
                    state,
                    const DashboardPlaceholderPage(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.branches,
                pageBuilder: (context, state) {
                  return _fadePage(
                    state,
                    const BranchesPlaceholderPage(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.settings,
                pageBuilder: (context, state) {
                  return _fadePage(
                    state,
                    const SettingsPlaceholderPage(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.pageTransition,
    reverseTransitionDuration: AppDurations.pageTransition,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

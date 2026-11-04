import 'dart:async';

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
import 'package:feemanager/features/batches/presentation/cubit/batch_form_cubit.dart';
import 'package:feemanager/features/batches/presentation/pages/batch_detail_page.dart';
import 'package:feemanager/features/batches/presentation/pages/batch_form_page.dart';
import 'package:feemanager/features/branches/presentation/cubit/branch_detail_cubit.dart';
import 'package:feemanager/features/branches/presentation/cubit/branch_form_cubit.dart';
import 'package:feemanager/features/branches/presentation/cubit/branch_list_cubit.dart';
import 'package:feemanager/features/branches/presentation/pages/branch_detail_page.dart';
import 'package:feemanager/features/branches/presentation/pages/branch_form_page.dart';
import 'package:feemanager/features/branches/presentation/pages/branches_page.dart';
import 'package:feemanager/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:feemanager/features/dashboard/presentation/cubit/pending_receipts_cubit.dart';
import 'package:feemanager/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:feemanager/features/dashboard/presentation/pages/pending_receipts_page.dart';
import 'package:feemanager/features/settings/presentation/cubit/institute_settings_form_cubit.dart';
import 'package:feemanager/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:feemanager/features/settings/presentation/cubit/template_settings_form_cubit.dart';
import 'package:feemanager/features/settings/presentation/pages/institute_settings_page.dart';
import 'package:feemanager/features/settings/presentation/pages/settings_page.dart';
import 'package:feemanager/features/settings/presentation/pages/template_settings_page.dart';
import 'package:feemanager/features/students/presentation/cubit/import_students_cubit.dart';
import 'package:feemanager/features/students/presentation/cubit/student_detail_cubit.dart';
import 'package:feemanager/features/students/presentation/cubit/student_form_cubit.dart';
import 'package:feemanager/features/students/presentation/pages/import_students_page.dart';
import 'package:feemanager/features/students/presentation/pages/student_detail_page.dart';
import 'package:feemanager/features/students/presentation/pages/student_form_page.dart';
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
                    BlocProvider(
                      create: (_) => sl<DashboardCubit>()..started(),
                      child: const DashboardPage(),
                    ),
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'pending-receipts',
                    parentNavigatorKey: rootKey,
                    builder: (context, state) {
                      final monthKey = state.extra as String? ?? '';
                      return BlocProvider(
                        create: (_) {
                          final cubit = sl<PendingReceiptsCubit>();
                          unawaited(cubit.started(monthKey));
                          return cubit;
                        },
                        child: PendingReceiptsPage(monthKey: monthKey),
                      );
                    },
                  ),
                ],
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
                    BlocProvider(
                      create: (_) => sl<BranchListCubit>()..started(),
                      child: const BranchesPage(),
                    ),
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
                    BlocProvider(
                      create: (_) => sl<SettingsCubit>()..started(),
                      child: const SettingsPage(),
                    ),
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'institute',
                    parentNavigatorKey: rootKey,
                    builder: (context, state) {
                      return BlocProvider(
                        create: (_) =>
                            sl<InstituteSettingsFormCubit>()..started(),
                        child: const InstituteSettingsPage(),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'template',
                    parentNavigatorKey: rootKey,
                    builder: (context, state) {
                      return BlocProvider(
                        create: (_) =>
                            sl<TemplateSettingsFormCubit>()..started(),
                        child: const TemplateSettingsPage(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.branchNew,
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<BranchFormCubit>()..initCreate(),
            child: const BranchFormPage(isEditing: false),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.branchDetail,
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final branchId = state.pathParameters['branchId']!;
          return BlocProvider(
            create: (_) {
              final cubit = sl<BranchDetailCubit>();
              unawaited(cubit.started(branchId));
              return cubit;
            },
            child: BranchDetailPage(branchId: branchId),
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'edit',
            parentNavigatorKey: rootKey,
            builder: (context, state) {
              final branchId = state.pathParameters['branchId']!;
          return BlocProvider(
            create: (_) {
              final cubit = sl<BranchFormCubit>();
              unawaited(cubit.initEdit(branchId));
              return cubit;
            },
            child: const BranchFormPage(isEditing: true),
          );
            },
          ),
          GoRoute(
            path: 'batches/new',
            parentNavigatorKey: rootKey,
            builder: (context, state) {
              final branchId = state.pathParameters['branchId']!;
              return BlocProvider(
                create: (_) {
                  final cubit = sl<BatchFormCubit>();
                  unawaited(cubit.initCreate(branchId));
                  return cubit;
                },
                child: const BatchFormPage(isEditing: false),
              );
            },
          ),
          GoRoute(
            path: 'batches/:batchId',
            parentNavigatorKey: rootKey,
            builder: (context, state) {
              final branchId = state.pathParameters['branchId']!;
              final batchId = state.pathParameters['batchId']!;
              return BatchDetailPage(
                branchId: branchId,
                batchId: batchId,
              );
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'edit',
                parentNavigatorKey: rootKey,
                builder: (context, state) {
                  final branchId = state.pathParameters['branchId']!;
                  final batchId = state.pathParameters['batchId']!;
                  return BlocProvider(
                    create: (_) {
                      final cubit = sl<BatchFormCubit>();
                      unawaited(cubit.initEdit(branchId, batchId));
                      return cubit;
                    },
                    child: const BatchFormPage(isEditing: true),
                  );
                },
              ),
              GoRoute(
                path: 'students/new',
                parentNavigatorKey: rootKey,
                builder: (context, state) {
                  final branchId = state.pathParameters['branchId']!;
                  final batchId = state.pathParameters['batchId']!;
                  return BlocProvider(
                    create: (_) {
                      final cubit = sl<StudentFormCubit>();
                      unawaited(cubit.initCreate(branchId, batchId));
                      return cubit;
                    },
                    child: const StudentFormPage(isEditing: false),
                  );
                },
              ),
              GoRoute(
                path: 'students/:studentId',
                parentNavigatorKey: rootKey,
                builder: (context, state) {
                  final branchId = state.pathParameters['branchId']!;
                  final batchId = state.pathParameters['batchId']!;
                  final studentId = state.pathParameters['studentId']!;
                  return BlocProvider(
                    create: (_) {
                      final cubit = sl<StudentDetailCubit>();
                      unawaited(
                        cubit.started(branchId, batchId, studentId),
                      );
                      return cubit;
                    },
                    child: StudentDetailPage(
                      branchId: branchId,
                      batchId: batchId,
                      studentId: studentId,
                    ),
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: rootKey,
                    builder: (context, state) {
                      final branchId = state.pathParameters['branchId']!;
                      final batchId = state.pathParameters['batchId']!;
                      final studentId = state.pathParameters['studentId']!;
                      return BlocProvider(
                        create: (_) {
                          final cubit = sl<StudentFormCubit>();
                          unawaited(
                            cubit.initEdit(branchId, batchId, studentId),
                          );
                          return cubit;
                        },
                        child: const StudentFormPage(isEditing: true),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'import',
                parentNavigatorKey: rootKey,
                builder: (context, state) {
                  final branchId = state.pathParameters['branchId']!;
                  final batchId = state.pathParameters['batchId']!;
                  final defaultFee = state.extra as int? ?? 0;
                  return BlocProvider(
                    create: (_) {
                      final cubit = sl<ImportStudentsCubit>()
                        ..started(
                          branchId: branchId,
                          batchId: batchId,
                          defaultFee: defaultFee,
                        );
                      return cubit;
                    },
                    child: const ImportStudentsPage(),
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

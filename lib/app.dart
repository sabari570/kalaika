import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/router/app_router.dart';
import 'package:feemanager/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Root widget configuring theme and navigation.
class KalaikaApp extends StatefulWidget {
  /// Creates the Kalaika application widget.
  const KalaikaApp({super.key});

  @override
  State<KalaikaApp> createState() => _KalaikaAppState();
}

class _KalaikaAppState extends State<KalaikaApp> {
  late final GoRouter _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appTitle,
      theme: AppTheme.dark(),
      routerConfig: _router,
      builder: (context, child) {
        final scaled = MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.textScalerOf(context).clamp(
            maxScaleFactor: 1.3,
          ),
        );
        return MediaQuery(data: scaled, child: child ?? const SizedBox());
      },
    );
  }
}

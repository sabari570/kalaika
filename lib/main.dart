import 'package:feemanager/app.dart';
import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/core/firebase/firebase_app_check_config.dart';
import 'package:feemanager/core/firebase/firebase_emulator_config.dart';
import 'package:feemanager/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application entry point.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await FirebaseAppCheckConfig.activateIfNeeded();
  await FirebaseEmulatorConfig.connectIfEnabled();
  if (kReleaseMode) {
    GoogleFonts.config.allowRuntimeFetching = false;
  }
  configureDependencies();
  runApp(const KalaikaApp());
}

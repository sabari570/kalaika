import 'package:feemanager/app.dart';
import 'package:feemanager/core/di/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application entry point.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) {
    GoogleFonts.config.allowRuntimeFetching = false;
  }
  configureDependencies();
  runApp(const KalaikaApp());
}

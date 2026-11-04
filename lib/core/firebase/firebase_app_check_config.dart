import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Activates Firebase App Check for debug builds (debug provider on Android).
abstract final class FirebaseAppCheckConfig {
  /// Installs App Check so Cloud Functions stop warning about missing tokens.
  static Future<void> activateIfNeeded() async {
    if (!kDebugMode) {
      return;
    }
    await FirebaseAppCheck.instance.activate(
      providerAndroid: const AndroidDebugProvider(),
      providerApple: const AppleDebugProvider(),
    );
    await _logStartupStatus();
  }

  static Future<void> _logStartupStatus() async {
    try {
      final token = await FirebaseAppCheck.instance.getToken(true);
      if (token != null && token.isNotEmpty) {
        debugPrint('Firebase App Check: debug token accepted.');
        return;
      }
      debugPrint(
        'Firebase App Check: no token yet. In logcat, filter '
        'DebugAppCheckProvider, copy the UUID, and add it under Firebase '
        'Console > App Check > Manage debug tokens. Then restart the app.',
      );
    } on Object {
      debugPrint(
        'Firebase App Check: token request failed. Register the debug UUID '
        'from logcat if Cloud Functions reject requests.',
      );
    }
  }
}

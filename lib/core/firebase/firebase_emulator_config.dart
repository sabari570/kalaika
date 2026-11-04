import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Connects Firestore, Cloud Functions and Storage to local emulators.
class FirebaseEmulatorConfig {
  FirebaseEmulatorConfig._();

  static const String _useEmulatorsFlag = 'USE_EMULATORS';
  static const String _emulatorHostFlag = 'EMULATOR_HOST';

  static const int firestorePort = 8080;
  static const int functionsPort = 5001;
  static const int storagePort = 9199;

  /// True when `--dart-define=USE_EMULATORS=true`.
  static bool get useEmulators {
    const value = String.fromEnvironment(
      _useEmulatorsFlag,
      defaultValue: 'false',
    );
    return value.toLowerCase() == 'true';
  }

  /// Host from `--dart-define=EMULATOR_HOST=...` (10.0.2.2 on Android).
  static String get emulatorHost {
    const value = String.fromEnvironment(
      _emulatorHostFlag,
      defaultValue: '127.0.0.1',
    );
    return value;
  }

  /// Points Firebase SDKs at emulators. Authentication stays on production.
  static Future<void> connectIfEnabled() async {
    if (!useEmulators) {
      return;
    }
    final host = emulatorHost;
    FirebaseFirestore.instance
      ..settings = const Settings(
        persistenceEnabled: false,
      )
      ..useFirestoreEmulator(host, firestorePort);
    FirebaseFunctions.instanceFor(region: 'asia-south1')
        .useFunctionsEmulator(host, functionsPort);
    await FirebaseStorage.instance.useStorageEmulator(host, storagePort);
    if (kDebugMode) {
      debugPrint(
        'Firebase emulators: host=$host '
        '(Firestore $firestorePort, Functions $functionsPort, '
        'Storage $storagePort)',
      );
      if (host == '10.0.2.2') {
        debugPrint(
          'Emulator host 10.0.2.2 is for the Android emulator only. '
          'On a physical device, use your computer LAN IP as EMULATOR_HOST.',
        );
      }
    }
  }

  /// Rewrites a Storage URL so the device can reach the local emulator.
  static String rewriteStorageUrlForDevice(String url) {
    final uri = Uri.parse(url);
    if (uri.host.contains('firebasestorage.googleapis.com')) {
      return Uri(
        scheme: 'http',
        host: emulatorHost,
        port: storagePort,
        path: uri.path,
        queryParameters: uri.queryParameters,
      ).toString();
    }
    if ((uri.host == '127.0.0.1' || uri.host == 'localhost') &&
        uri.port == storagePort) {
      return uri.replace(host: emulatorHost).toString();
    }
    return url;
  }
}

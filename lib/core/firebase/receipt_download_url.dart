import 'package:feemanager/core/firebase/firebase_emulator_config.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Resolves receipt links for in-app viewing (including Storage emulator).
abstract final class ReceiptDownloadUrl {
  /// Returns a URL suitable for opening in an external browser, or null.
  static Future<String?> resolveForOpen({
    required String? receiptUrl,
    required String? receiptPath,
  }) async {
    if (FirebaseEmulatorConfig.useEmulators &&
        receiptPath != null &&
        receiptPath.isNotEmpty) {
      try {
        final emulatorUrl = await FirebaseStorage.instance
            .ref(receiptPath)
            .getDownloadURL();
        return FirebaseEmulatorConfig.rewriteStorageUrlForDevice(emulatorUrl);
      } on Object {
        // Fall back to rewriting the stored production-style URL.
      }
    }
    if (receiptUrl == null || receiptUrl.isEmpty) {
      return null;
    }
    if (FirebaseEmulatorConfig.useEmulators) {
      return FirebaseEmulatorConfig.rewriteStorageUrlForDevice(receiptUrl);
    }
    return receiptUrl;
  }
}

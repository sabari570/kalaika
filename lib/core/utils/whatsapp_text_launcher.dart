import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/utils/firestore_debug_log.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens WhatsApp with a prefilled text message via `wa.me`.
abstract final class WhatsAppTextLauncher {
  /// Launches WhatsApp chat for [phoneDigits] with [text] prefilled.
  ///
  /// [phoneDigits] must include the country code
  /// (for example `91` plus ten digits).
  static Future<bool> openChat({
    required String phoneDigits,
    required String text,
  }) async {
    final uri = Uri.https(
      'wa.me',
      '/$phoneDigits',
      <String, String>{'text': text},
    );
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (kDebugMode) {
        FirestoreDebugLog.operation(
          'WhatsAppTextLauncher.openChat',
          details: <String, Object?>{'launched': launched},
        );
      }
      return launched;
    } on Object catch (error, stackTrace) {
      FirestoreDebugLog.failure(
        'WhatsAppTextLauncher.openChat',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// User-facing error when [openChat] returns false.
  static const String openFailedMessage = AppStrings.whatsappMessageOpenFailed;
}

import 'package:feemanager/core/constants/app_defaults.dart';

/// How fee confirmation is delivered on WhatsApp.
enum WhatsAppDeliveryMode {
  /// Open WhatsApp with the message template only.
  message,

  /// Open WhatsApp with the receipt PDF only.
  receipt;

  /// Default preference for new and legacy accounts.
  static const WhatsAppDeliveryMode defaultMode = WhatsAppDeliveryMode.receipt;
}

/// Serialization helpers for [WhatsAppDeliveryMode].
abstract final class WhatsAppDeliveryModeCodec {
  /// Firestore / storage value for message mode.
  static const String messageValue = 'message';

  /// Firestore / storage value for receipt mode.
  static const String receiptValue = AppDefaults.whatsappDeliveryModeValue;

  /// Parses a stored value; unknown or null becomes receipt mode.
  static WhatsAppDeliveryMode parse(String? raw) {
    switch (raw?.trim()) {
      case messageValue:
        return WhatsAppDeliveryMode.message;
      case receiptValue:
      default:
        return WhatsAppDeliveryMode.defaultMode;
    }
  }

  /// Serializes [mode] for Firestore.
  static String serialize(WhatsAppDeliveryMode mode) {
    return switch (mode) {
      WhatsAppDeliveryMode.message => messageValue,
      WhatsAppDeliveryMode.receipt => receiptValue,
    };
  }
}

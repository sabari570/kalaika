import 'dart:io';

import 'package:feemanager/core/utils/firestore_debug_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Opens WhatsApp on Android with a PDF and message for one contact.
abstract final class WhatsAppShareUtils {
  static const MethodChannel _channel = MethodChannel(
    'com.kalaika.feemanager/whatsapp',
  );

  static bool _nativeChannelMissingLogged = false;

  /// Whether the Android method channel is registered (requires full restart
  /// after native code changes, not hot reload).
  static Future<bool> isNativeChannelAvailable() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      await _channel.invokeMethod<bool>('isWhatsAppInstalled');
      return true;
    } on MissingPluginException {
      _logMissingPluginOnce();
      return false;
    } on Object catch (error, stackTrace) {
      FirestoreDebugLog.failure(
        'WhatsAppShareUtils.isNativeChannelAvailable',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Whether WhatsApp or WhatsApp Business is installed on the device.
  static Future<bool> isWhatsAppInstalled() async {
    if (!Platform.isAndroid) {
      return false;
    }
    if (!await isNativeChannelAvailable()) {
      return false;
    }
    try {
      final installed = await _channel.invokeMethod<bool>(
        'isWhatsAppInstalled',
      );
      return installed ?? false;
    } on Object catch (error, stackTrace) {
      FirestoreDebugLog.failure(
        'WhatsAppShareUtils.isWhatsAppInstalled',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Shares [pdfPath] to the chat for [phoneDigits] (`91` + 10 digits).
  static Future<bool> sharePdfToChat({
    required String pdfPath,
    required String phoneDigits,
    String? text,
  }) async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final opened = await _channel.invokeMethod<bool>(
        'sharePdfToChat',
        <String, Object?>{
          'pdfPath': pdfPath,
          'phoneDigits': phoneDigits,
          'text': text,
        },
      );
      if (kDebugMode) {
        FirestoreDebugLog.operation(
          'WhatsAppShareUtils.sharePdfToChat',
          details: <String, Object?>{'opened': opened ?? false},
        );
      }
      return opened ?? false;
    } on MissingPluginException {
      _logMissingPluginOnce();
      return false;
    } on Object catch (error, stackTrace) {
      FirestoreDebugLog.failure(
        'WhatsAppShareUtils.sharePdfToChat',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Opens WhatsApp with [pdfPath] and optional [text]; user picks the chat.
  static Future<bool> sharePdfToWhatsAppApp({
    required String pdfPath,
    String? text,
  }) async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final opened = await _channel.invokeMethod<bool>(
        'sharePdfToWhatsApp',
        <String, Object?>{
          'pdfPath': pdfPath,
          'text': text,
        },
      );
      if (kDebugMode) {
        FirestoreDebugLog.operation(
          'WhatsAppShareUtils.sharePdfToWhatsAppApp',
          details: <String, Object?>{'opened': opened ?? false},
        );
      }
      return opened ?? false;
    } on MissingPluginException {
      _logMissingPluginOnce();
      return false;
    } on Object catch (error, stackTrace) {
      FirestoreDebugLog.failure(
        'WhatsAppShareUtils.sharePdfToWhatsAppApp',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static void _logMissingPluginOnce() {
    if (_nativeChannelMissingLogged || !kDebugMode) {
      return;
    }
    _nativeChannelMissingLogged = true;
    FirestoreDebugLog.operation(
      'WhatsAppShareUtils',
      details: <String, Object?>{
        'note': 'Native WhatsApp channel unavailable. '
            'Stop the app and run again (not hot reload).',
      },
    );
  }
}

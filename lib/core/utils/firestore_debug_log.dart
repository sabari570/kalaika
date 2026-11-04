import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Debug-only logging for Firestore reads, writes, and failures.
abstract final class FirestoreDebugLog {
  static const String _name = 'KalaikaFirestore';

  /// Logs the start of a Firestore operation.
  static void operation(
    String name, {
    String? path,
    Map<String, Object?>? details,
  }) {
    if (!kDebugMode) {
      return;
    }
    final buffer = StringBuffer(name);
    if (path != null && path.isNotEmpty) {
      buffer.write(' path=$path');
    }
    if (details != null && details.isNotEmpty) {
      buffer.write(' $details');
    }
    developer.log(buffer.toString(), name: _name);
  }

  /// Logs a successful operation completion.
  static void success(String name, {String? path}) {
    if (!kDebugMode) {
      return;
    }
    developer.log(
      '$name OK${path == null ? '' : ' path=$path'}',
      name: _name,
    );
  }

  /// Logs error details for repository and data-source boundaries.
  static void failure(
    String operation, {
    required Object error,
    StackTrace? stackTrace,
    String? path,
  }) {
    if (!kDebugMode) {
      return;
    }
    final type = error.runtimeType;
    final code = _errorCode(error);
    final message = _errorMessage(error);
    developer.log(
      '$operation FAILED type=$type code=$code message=$message'
      '${path == null ? '' : ' path=$path'}',
      name: _name,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static String? _errorCode(Object error) {
    if (error is FirebaseException) {
      return error.code;
    }
    return null;
  }

  static String _errorMessage(Object error) {
    if (error is StateError) {
      return error.message;
    }
    if (error is FirebaseException) {
      return error.message ?? error.toString();
    }
    return error.toString();
  }
}

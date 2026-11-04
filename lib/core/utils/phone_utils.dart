import 'package:feemanager/core/constants/app_strings.dart';

/// Result of normalizing a phone number string.
sealed class PhoneNormalizeResult {
  const PhoneNormalizeResult();
}

/// Normalized digits ready to store.
final class PhoneNormalized extends PhoneNormalizeResult {
  /// Creates a successful normalization.
  const PhoneNormalized(this.digits);

  /// Stored digits only, for example `919074283081`.
  final String digits;
}

/// The value could not be used.
final class PhoneInvalid extends PhoneNormalizeResult {
  /// Creates an invalid result with a formal [message].
  const PhoneInvalid(this.message);

  /// User-presentable reason.
  final String message;
}

/// Bulk import requires manual correction before import.
final class PhoneNeedsCorrection extends PhoneNormalizeResult {
  /// Creates a needs-correction result.
  const PhoneNeedsCorrection(this.message);

  /// User-presentable reason.
  final String message;
}

/// Form entry may proceed after the teacher confirms the number.
final class PhoneNeedsConfirmation extends PhoneNormalizeResult {
  /// Creates a confirmation result.
  const PhoneNeedsConfirmation(this.digits);

  /// Proposed stored digits.
  final String digits;
}

/// Normalizes Indian and international phone numbers for storage.
abstract final class PhoneUtils {
  /// Strips formatting characters from [raw] input.
  static String stripFormatting(String raw) {
    var value = raw.trim();
    if (value.startsWith('+')) {
      value = value.substring(1);
    }
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      if (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Converts Excel cell text, including scientific notation, to digits.
  static String cellTextToPlainDigits(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    final lower = trimmed.toLowerCase();
    if (lower.contains('e')) {
      final parsed = double.tryParse(trimmed.replaceAll(',', ''));
      if (parsed != null) {
        return parsed.toStringAsFixed(0);
      }
    }
    return stripFormatting(trimmed);
  }

  /// Normalizes [raw] for storage.
  static PhoneNormalizeResult normalize(
    String raw, {
    required bool bulkImport,
  }) {
    final digits = cellTextToPlainDigits(raw);
    if (digits.isEmpty) {
      return const PhoneInvalid(AppStrings.phoneInvalid);
    }
    final length = digits.length;
    if (length == 10) {
      return PhoneNormalized('91$digits');
    }
    if (length == 11 && digits.startsWith('0')) {
      return PhoneNormalized('91${digits.substring(1)}');
    }
    if (length == 12 && digits.startsWith('91')) {
      return PhoneNormalized(digits);
    }
    if (length >= 11 && length <= 15) {
      if (bulkImport) {
        return const PhoneNeedsCorrection(AppStrings.phoneNeedsCorrection);
      }
      return PhoneNeedsConfirmation(digits);
    }
    return const PhoneInvalid(AppStrings.phoneInvalid);
  }

  /// Formats stored [digits] for display (India uses +91 and a space).
  ///
  /// Storage remains digits only, for example `919074283081`, without `+`.
  static String formatForDisplay(String digits) {
    final stripped = stripFormatting(digits);
    if (stripped.length == 12 && stripped.startsWith('91')) {
      final local = stripped.substring(2);
      if (local.length == 10) {
        return '+91 ${local.substring(0, 5)} ${local.substring(5)}';
      }
    }
    if (stripped.length == 10) {
      return '+91 ${stripped.substring(0, 5)} ${stripped.substring(5)}';
    }
    if (stripped.isEmpty) {
      return '';
    }
    return '+$stripped';
  }

  /// Returns normalized Indian WhatsApp digits when [storedOrRaw] is valid.
  ///
  /// Used to open WhatsApp directly; ambiguous numbers return null so the
  /// system share sheet is shown instead.
  static String? whatsappDigitsForDirectShare(String storedOrRaw) {
    if (storedOrRaw.trim().isEmpty) {
      return null;
    }
    final result = normalize(storedOrRaw, bulkImport: false);
    if (result is! PhoneNormalized) {
      return null;
    }
    final digits = result.digits;
    if (digits.length == 12 &&
        digits.startsWith('91') &&
        digits.substring(2).length == 10) {
      return digits;
    }
    return null;
  }
}

/// Receipt number formatting for client-side payments.
abstract final class ReceiptNumberUtils {
  /// Formats `KLK-{year}-{6-digit sequence}`.
  static String format(int year, int sequence) {
    final padded = sequence.toString().padLeft(6, '0');
    return 'KLK-$year-$padded';
  }
}

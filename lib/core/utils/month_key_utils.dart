/// Month keys for fee tracking (Asia/Kolkata calendar months).
abstract final class MonthKeyUtils {
  /// Formats [month] as `yyyy-MM` for payment documents.
  static String toMonthKey(DateTime month) {
    final normalized = DateTime(month.year, month.month);
    final mm = normalized.month.toString().padLeft(2, '0');
    return '${normalized.year}-$mm';
  }

  /// Builds a payment document id for [studentId] and [month].
  static String paymentDocumentId(String studentId, DateTime month) {
    final normalized = DateTime(month.year, month.month);
    final mm = normalized.month.toString().padLeft(2, '0');
    return '${studentId}_${normalized.year}$mm';
  }
}

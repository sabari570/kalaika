/// Payment document id helpers.
abstract final class PaymentDocumentId {
  /// Builds `{studentId}_{yyyyMM}` from a month key.
  static String fromStudentAndMonth(String studentId, String monthKey) {
    final compact = monthKey.replaceAll('-', '');
    return '${studentId}_$compact';
  }
}

/// Calendar helpers for fee months (Asia/Kolkata; no daylight saving).
abstract final class DateUtils {
  static const Duration _kolkataOffset = Duration(hours: 5, minutes: 30);

  /// Current date and time in Asia/Kolkata.
  static DateTime kolkataNow() {
    return DateTime.now().toUtc().add(_kolkataOffset);
  }

  /// First day of the calendar month in Asia/Kolkata.
  static DateTime kolkataMonthStart({DateTime? reference}) {
    final ref = reference ?? kolkataNow();
    return DateTime(ref.year, ref.month);
  }
}

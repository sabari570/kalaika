/// Session-scoped selected month for the fee tracker.
abstract final class FeeMonthSession {
  static DateTime? _selectedMonth;

  /// Returns the persisted month or [fallback].
  static DateTime current({DateTime? fallback}) {
    final now = fallback ?? DateTime.now();
    return _selectedMonth ?? DateTime(now.year, now.month);
  }

  /// Persists [month] for the app session.
  static void save(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
  }
}

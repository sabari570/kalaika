import 'package:feemanager/core/utils/date_utils.dart';

/// Session-scoped selected month for the fee tracker.
abstract final class FeeMonthSession {
  static DateTime? _selectedMonth;

  /// Returns the persisted month or the current month in Asia/Kolkata.
  static DateTime current() {
    return _selectedMonth ?? DateUtils.kolkataMonthStart();
  }

  /// Persists [month] for the app session.
  static void save(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
  }
}

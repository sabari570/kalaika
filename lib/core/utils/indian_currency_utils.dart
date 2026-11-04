import 'package:intl/intl.dart';

/// Indian currency formatting for receipts.
abstract final class IndianCurrencyUtils {
  static final NumberFormat _format = NumberFormat.decimalPattern('en_IN');

  /// Formats whole rupees with Indian grouping.
  static String format(int amount) {
    return _format.format(amount);
  }
}

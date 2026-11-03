/// Stored payment mode values.
abstract final class PaymentConstants {
  /// Cash payment.
  static const String modeCash = 'cash';

  /// UPI payment.
  static const String modeUpi = 'upi';

  /// Bank transfer.
  static const String modeBank = 'bank';

  /// Other mode.
  static const String modeOther = 'other';

  /// Debug default mode.
  static const String debugMode = modeCash;
}

/// Default institute and template values for new user documents.
abstract final class AppDefaults {
  /// Default institute name on receipts.
  static const String instituteName = 'Kalaika';

  /// Default institute tagline.
  static const String instituteTagline = 'By Lakshmi Kumaran';

  /// Default institute contact phone (digits as stored on user profile).
  static const String institutePhone = '9074283081';

  /// Default WhatsApp message template for new accounts.
  static const String messageTemplate = '''
Dear {recipient_name},

This is to confirm receipt of Rs. {amount} towards the {month} {year} class fee of {student_name} ({batch_name}, {branch_name}).

Receipt No: {receipt_no}
Receipt: {receipt_url}

Regards,
{institute_name}''';
}

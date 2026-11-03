/// Firestore collection and field name constants.
abstract final class FirestoreKeys {
  /// Root users collection.
  static const String users = 'users';

  /// User profile fields.
  static const String displayName = 'displayName';
  static const String email = 'email';
  static const String createdAt = 'createdAt';
  static const String institute = 'institute';
  static const String tagline = 'tagline';
  static const String addressLines = 'addressLines';
  static const String footerNote = 'footerNote';
  static const String signatory = 'signatory';
  static const String phone = 'phone';
  static const String messageTemplate = 'messageTemplate';

  /// Meta subcollection under a user.
  static const String meta = 'meta';
  static const String counters = 'counters';
  static const String receiptSeq = 'receiptSeq';

  /// Monthly rollup documents.
  static const String summaries = 'summaries';

  /// Branch collection segment.
  static const String branches = 'branches';
  static const String name = 'name';
  static const String location = 'location';
  static const String contactNumber = 'contactNumber';
  static const String batchCount = 'batchCount';
  static const String studentCount = 'studentCount';
  static const String isActive = 'isActive';

  /// Batch collection segment.
  static const String batches = 'batches';
  static const String ownerId = 'ownerId';
  static const String branchId = 'branchId';
  static const String branchName = 'branchName';
  static const String danceStyle = 'danceStyle';
  static const String mode = 'mode';
  static const String days = 'days';
  static const String classTime = 'classTime';
  static const String defaultFee = 'defaultFee';
  static const String expectedMonthlyTotal = 'expectedMonthlyTotal';

  /// Student collection segment.
  static const String students = 'students';
  static const String fullName = 'fullName';
  static const String phoneNumber = 'phoneNumber';
  static const String whatsappNumber = 'whatsappNumber';
  static const String dateOfBirth = 'dateOfBirth';
  static const String age = 'age';
  static const String guardianName = 'guardianName';
  static const String guardianPhone = 'guardianPhone';
  static const String address = 'address';
  static const String monthlyFee = 'monthlyFee';

  /// Payment collection segment.
  static const String payments = 'payments';
  static const String batchId = 'batchId';
  static const String studentId = 'studentId';
  static const String studentName = 'studentName';
  static const String month = 'month';
  static const String amount = 'amount';
  static const String batchFee = 'batchFee';
  static const String paidOn = 'paidOn';
  static const String note = 'note';
  static const String status = 'status';
  static const String receiptNo = 'receiptNo';
  static const String receiptPath = 'receiptPath';
  static const String receiptUrl = 'receiptUrl';
  static const String sentAt = 'sentAt';
  static const String sentVia = 'sentVia';
  static const String voided = 'voided';

  /// Payment status values.
  static const String statusPaid = 'paid';
  static const String statusSent = 'sent';
  static const String statusVoided = 'voided';
}

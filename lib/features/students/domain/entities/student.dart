import 'package:equatable/equatable.dart';

/// A student enrolled in a batch.
class Student extends Equatable {
  /// Creates a student entity.
  const Student({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.dateOfBirth,
    required this.age,
    required this.guardianName,
    required this.guardianPhone,
    required this.address,
    required this.monthlyFee,
    required this.isActive,
    required this.createdAt,
  });

  /// Firestore document id.
  final String id;

  /// Student full name.
  final String fullName;

  /// Normalized phone digits or null.
  final String? phoneNumber;

  /// Normalized WhatsApp digits.
  final String whatsappNumber;

  /// Optional date of birth.
  final DateTime? dateOfBirth;

  /// Stored age when no date of birth exists.
  final int? age;

  /// Guardian or parent name.
  final String? guardianName;

  /// Normalized guardian phone or null.
  final String? guardianPhone;

  /// Postal address text.
  final String? address;

  /// Monthly fee in whole rupees.
  final int monthlyFee;

  /// Whether the student appears in the fee tracker.
  final bool isActive;

  /// Document creation time.
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    fullName,
    phoneNumber,
    whatsappNumber,
    dateOfBirth,
    age,
    guardianName,
    guardianPhone,
    address,
    monthlyFee,
    isActive,
    createdAt,
  ];
}

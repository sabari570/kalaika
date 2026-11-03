import 'package:equatable/equatable.dart';

/// Input for creating or updating a student.
class StudentDraft extends Equatable {
  /// Creates student form values.
  const StudentDraft({
    required this.fullName,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.dateOfBirth,
    required this.age,
    required this.guardianName,
    required this.guardianPhone,
    required this.address,
    required this.monthlyFee,
  });

  /// Required full name.
  final String fullName;

  /// Optional normalized phone digits.
  final String? phoneNumber;

  /// Required normalized WhatsApp digits.
  final String whatsappNumber;

  /// Optional date of birth.
  final DateTime? dateOfBirth;

  /// Manual age when no date of birth is set.
  final int? age;

  /// Optional guardian name.
  final String? guardianName;

  /// Optional normalized guardian phone.
  final String? guardianPhone;

  /// Optional address.
  final String? address;

  /// Monthly fee in rupees.
  final int monthlyFee;

  @override
  List<Object?> get props => <Object?>[
    fullName,
    phoneNumber,
    whatsappNumber,
    dateOfBirth,
    age,
    guardianName,
    guardianPhone,
    address,
    monthlyFee,
  ];
}

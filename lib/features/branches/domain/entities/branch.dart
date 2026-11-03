import 'package:equatable/equatable.dart';

/// A teaching location under the signed-in teacher account.
class Branch extends Equatable {
  /// Creates a branch entity.
  const Branch({
    required this.id,
    required this.name,
    required this.location,
    required this.contactNumber,
    required this.batchCount,
    required this.studentCount,
    required this.isActive,
    required this.createdAt,
  });

  /// Firestore document id.
  final String id;

  /// Branch display name.
  final String name;

  /// Location or address text.
  final String location;

  /// Optional contact number digits.
  final String contactNumber;

  /// Number of batches in this branch.
  final int batchCount;

  /// Total active students across batches.
  final int studentCount;

  /// Whether the branch is active.
  final bool isActive;

  /// Document creation time.
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    location,
    contactNumber,
    batchCount,
    studentCount,
    isActive,
    createdAt,
  ];
}

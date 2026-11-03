import 'package:equatable/equatable.dart';

/// A class batch within a branch.
class Batch extends Equatable {
  /// Creates a batch entity.
  const Batch({
    required this.id,
    required this.ownerId,
    required this.branchId,
    required this.branchName,
    required this.name,
    required this.danceStyle,
    required this.mode,
    required this.days,
    required this.classTime,
    required this.defaultFee,
    required this.studentCount,
    required this.expectedMonthlyTotal,
    required this.isActive,
    required this.createdAt,
  });

  /// Document id.
  final String id;

  /// Teacher uid for collection group queries.
  final String ownerId;

  /// Parent branch id.
  final String branchId;

  /// Denormalized branch name.
  final String branchName;

  /// Batch display name.
  final String name;

  /// Dance style label.
  final String danceStyle;

  /// Stored mode (`offline`, `online`, `private`).
  final String mode;

  /// Selected weekday keys.
  final List<String> days;

  /// Optional class time text.
  final String classTime;

  /// Default monthly fee in whole rupees.
  final int defaultFee;

  /// Active student count.
  final int studentCount;

  /// Sum of active students' monthly fees.
  final int expectedMonthlyTotal;

  /// Whether the batch is active.
  final bool isActive;

  /// Document creation time.
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    ownerId,
    branchId,
    branchName,
    name,
    danceStyle,
    mode,
    days,
    classTime,
    defaultFee,
    studentCount,
    expectedMonthlyTotal,
    isActive,
    createdAt,
  ];
}

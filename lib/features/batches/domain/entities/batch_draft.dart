import 'package:equatable/equatable.dart';

/// Whether a batch fee change applies to existing students.
enum BatchFeeApplyScope {
  /// Only affects students added after this save.
  newStudentsOnly,

  /// Updates every active student's monthly fee.
  allActiveStudents,
}

/// Input for creating or updating a batch.
class BatchDraft extends Equatable {
  /// Creates batch form values.
  const BatchDraft({
    required this.name,
    required this.danceStyle,
    required this.mode,
    required this.days,
    required this.classTime,
    required this.defaultFee,
    this.feeApplyScope = BatchFeeApplyScope.newStudentsOnly,
  });

  /// Required batch name.
  final String name;

  /// Selected or custom dance style.
  final String danceStyle;

  /// Stored mode value.
  final String mode;

  /// Weekday keys.
  final List<String> days;

  /// Optional class time.
  final String classTime;

  /// Default monthly fee in rupees.
  final int defaultFee;

  /// Fee propagation choice when editing an existing batch.
  final BatchFeeApplyScope feeApplyScope;

  @override
  List<Object?> get props => <Object?>[
    name,
    danceStyle,
    mode,
    days,
    classTime,
    defaultFee,
    feeApplyScope,
  ];
}

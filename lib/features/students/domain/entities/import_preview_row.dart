import 'package:equatable/equatable.dart';
import 'package:feemanager/features/students/domain/entities/student_draft.dart';

/// Filter category for an import preview row.
enum ImportRowCategory {
  /// Ready to import.
  valid,

  /// Importable with warnings.
  warning,

  /// Must be corrected before import.
  needsCorrection,

  /// Duplicate in file or batch.
  duplicate,
}

/// One parsed row in the Excel import preview.
class ImportPreviewRow extends Equatable {
  /// Creates a preview row.
  const ImportPreviewRow({
    required this.rowNumber,
    required this.category,
    required this.messages,
    required this.draft,
  });

  /// Spreadsheet row number (1-based, including header).
  final int rowNumber;

  /// Validation category.
  final ImportRowCategory category;

  /// Warning or error messages for the row.
  final List<String> messages;

  /// Parsed student values when importable.
  final StudentDraft? draft;

  @override
  List<Object?> get props => <Object?>[rowNumber, category, messages, draft];
}

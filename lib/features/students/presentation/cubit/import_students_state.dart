import 'package:equatable/equatable.dart';
import 'package:feemanager/features/students/domain/entities/import_preview_row.dart';
import 'package:feemanager/features/students/domain/repositories/student_repository.dart';

/// Filter for import preview list.
enum ImportPreviewFilter {
  /// Valid rows.
  valid,

  /// Rows with warnings.
  warnings,

  /// Rows needing correction.
  needsCorrection,

  /// Duplicate rows.
  duplicates,
}

/// Excel import flow states.
sealed class ImportStudentsState extends Equatable {
  const ImportStudentsState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Waiting for file selection.
final class ImportStudentsIdle extends ImportStudentsState {
  const ImportStudentsIdle({
    required this.branchId,
    required this.batchId,
    required this.defaultFee,
  });

  final String branchId;
  final String batchId;
  final int defaultFee;

  @override
  List<Object?> get props => <Object?>[branchId, batchId, defaultFee];
}

/// Parsing workbook off the UI thread.
final class ImportStudentsParsing extends ImportStudentsState {
  const ImportStudentsParsing();
}

/// Preview ready for confirmation.
final class ImportStudentsPreview extends ImportStudentsState {
  const ImportStudentsPreview({
    required this.rows,
    required this.filter,
    required this.branchId,
    required this.batchId,
  });

  final List<ImportPreviewRow> rows;
  final ImportPreviewFilter filter;
  final String branchId;
  final String batchId;

  ImportStudentsPreview copyWith({
    ImportPreviewFilter? filter,
  }) {
    return ImportStudentsPreview(
      rows: rows,
      filter: filter ?? this.filter,
      branchId: branchId,
      batchId: batchId,
    );
  }

  @override
  List<Object?> get props => <Object?>[rows, filter, branchId, batchId];
}

/// Import write in progress.
final class ImportStudentsRunning extends ImportStudentsState {
  const ImportStudentsRunning(this.completedChunks, this.totalChunks);

  final int completedChunks;
  final int totalChunks;

  @override
  List<Object?> get props => <Object?>[completedChunks, totalChunks];
}

/// Import finished.
final class ImportStudentsComplete extends ImportStudentsState {
  const ImportStudentsComplete(this.result);

  final ImportStudentsResult result;

  @override
  List<Object?> get props => <Object?>[result];
}

/// Import failed.
final class ImportStudentsFailure extends ImportStudentsState {
  const ImportStudentsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

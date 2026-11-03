import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/students/domain/entities/import_preview_row.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:feemanager/features/students/domain/entities/student_draft.dart';
import 'package:feemanager/features/students/domain/entities/student_payment_summary.dart';

/// Student persistence and import operations.
abstract class StudentRepository {
  /// Streams students in a batch ordered by name.
  Stream<List<Student>> watchStudents(String branchId, String batchId);

  /// Reads all students once for duplicate detection.
  Future<Result<List<Student>>> listStudents(String branchId, String batchId);

  /// Loads one student.
  Future<Result<Student>> getStudent(
    String branchId,
    String batchId,
    String studentId,
  );

  /// Creates a student and updates counters.
  Future<Result<Student>> createStudent(
    String branchId,
    String batchId,
    StudentDraft draft,
  );

  /// Updates a student and adjusts fee totals when needed.
  Future<Result<Student>> updateStudent(
    String branchId,
    String batchId,
    String studentId,
    StudentDraft draft,
  );

  /// Sets whether a student is active and updates counters.
  Future<Result<void>> setStudentActive(
    String branchId,
    String batchId,
    String studentId, {
    required bool isActive,
  });

  /// Returns true when another student shares WhatsApp and name.
  Future<Result<bool>> hasDuplicateStudent({
    required String branchId,
    required String batchId,
    required String fullName,
    required String whatsappNumber,
    String? excludeStudentId,
  });

  /// Parses and validates an Excel workbook.
  Future<Result<List<ImportPreviewRow>>> parseImportPreview({
    required String branchId,
    required String batchId,
    required int defaultFee,
    required List<int> fileBytes,
  });

  /// Imports preview rows in chunks and updates counters once.
  Future<Result<ImportStudentsResult>> importStudents({
    required String branchId,
    required String batchId,
    required List<StudentDraft> drafts,
  });

  /// Builds a sample template workbook as bytes.
  Future<Result<List<int>>> buildSampleTemplateBytes();

  /// Loads recent payments for a student.
  Future<Result<List<StudentPaymentSummary>>> getPaymentHistory(
    String branchId,
    String batchId,
    String studentId,
  );
}

/// Outcome of a bulk import operation.
class ImportStudentsResult {
  /// Creates import statistics.
  const ImportStudentsResult({
    required this.imported,
    required this.skipped,
    required this.failed,
  });

  /// Successfully written rows.
  final int imported;

  /// Skipped rows (duplicates or invalid).
  final int skipped;

  /// Rows that failed during a chunk write.
  final int failed;
}

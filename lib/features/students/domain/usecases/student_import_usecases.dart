import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/students/domain/entities/import_preview_row.dart';
import 'package:feemanager/features/students/domain/entities/student_draft.dart';
import 'package:feemanager/features/students/domain/entities/student_payment_summary.dart';
import 'package:feemanager/features/students/domain/repositories/student_repository.dart';

/// Checks for duplicate students in a batch.
class HasDuplicateStudent
    implements UseCase<bool, HasDuplicateStudentParams> {
  /// Creates the use case.
  HasDuplicateStudent(this._repository);

  final StudentRepository _repository;

  @override
  Future<Result<bool>> call(HasDuplicateStudentParams params) {
    return _repository.hasDuplicateStudent(
      branchId: params.branchId,
      batchId: params.batchId,
      fullName: params.fullName,
      whatsappNumber: params.whatsappNumber,
      excludeStudentId: params.excludeStudentId,
    );
  }
}

/// Parameters for [HasDuplicateStudent].
class HasDuplicateStudentParams {
  /// Creates duplicate check parameters.
  const HasDuplicateStudentParams({
    required this.branchId,
    required this.batchId,
    required this.fullName,
    required this.whatsappNumber,
    this.excludeStudentId,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Full name to check.
  final String fullName;

  /// WhatsApp digits to check.
  final String whatsappNumber;

  /// Student id to exclude when editing.
  final String? excludeStudentId;
}

/// Parses an Excel file into import preview rows.
class ParseStudentImport
    implements UseCase<List<ImportPreviewRow>, ParseStudentImportParams> {
  /// Creates the use case.
  ParseStudentImport(this._repository);

  final StudentRepository _repository;

  @override
  Future<Result<List<ImportPreviewRow>>> call(
    ParseStudentImportParams params,
  ) {
    return _repository.parseImportPreview(
      branchId: params.branchId,
      batchId: params.batchId,
      defaultFee: params.defaultFee,
      fileBytes: params.fileBytes,
    );
  }
}

/// Parameters for [ParseStudentImport].
class ParseStudentImportParams {
  /// Creates parse parameters.
  const ParseStudentImportParams({
    required this.branchId,
    required this.batchId,
    required this.defaultFee,
    required this.fileBytes,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Batch default fee for imported rows.
  final int defaultFee;

  /// Raw workbook bytes.
  final List<int> fileBytes;
}

/// Imports validated student drafts.
class ImportStudents
    implements UseCase<ImportStudentsResult, ImportStudentsParams> {
  /// Creates the use case.
  ImportStudents(this._repository);

  final StudentRepository _repository;

  @override
  Future<Result<ImportStudentsResult>> call(ImportStudentsParams params) {
    return _repository.importStudents(
      branchId: params.branchId,
      batchId: params.batchId,
      drafts: params.drafts,
    );
  }
}

/// Parameters for [ImportStudents].
class ImportStudentsParams {
  /// Creates import parameters.
  const ImportStudentsParams({
    required this.branchId,
    required this.batchId,
    required this.drafts,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Rows to write.
  final List<StudentDraft> drafts;
}

/// Builds sample template bytes.
class BuildStudentTemplate implements UseCase<List<int>, NoParams> {
  /// Creates the use case.
  BuildStudentTemplate(this._repository);

  final StudentRepository _repository;

  @override
  Future<Result<List<int>>> call(NoParams params) {
    return _repository.buildSampleTemplateBytes();
  }
}

/// Loads payment history for a student.
class GetStudentPaymentHistory
    implements
        UseCase<List<StudentPaymentSummary>, GetStudentPaymentHistoryParams> {
  /// Creates the use case.
  GetStudentPaymentHistory(this._repository);

  final StudentRepository _repository;

  @override
  Future<Result<List<StudentPaymentSummary>>> call(
    GetStudentPaymentHistoryParams params,
  ) {
    return _repository.getPaymentHistory(
      params.branchId,
      params.batchId,
      params.studentId,
    );
  }
}

/// Parameters for [GetStudentPaymentHistory].
class GetStudentPaymentHistoryParams {
  /// Creates payment history parameters.
  const GetStudentPaymentHistoryParams({
    required this.branchId,
    required this.batchId,
    required this.studentId,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Student id.
  final String studentId;
}

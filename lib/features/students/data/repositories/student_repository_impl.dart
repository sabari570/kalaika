import 'package:feemanager/core/error/exception_mapper.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/students/data/datasources/student_remote_datasource.dart';
import 'package:feemanager/features/students/data/services/excel_workbook_parser.dart';
import 'package:feemanager/features/students/data/services/student_import_validator.dart';
import 'package:feemanager/features/students/data/services/student_template_builder.dart';
import 'package:feemanager/features/students/domain/entities/import_preview_row.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:feemanager/features/students/domain/entities/student_draft.dart';
import 'package:feemanager/features/students/domain/entities/student_payment_summary.dart';
import 'package:feemanager/features/students/domain/repositories/student_repository.dart';
import 'package:flutter/foundation.dart';

/// Firestore implementation of [StudentRepository].
class StudentRepositoryImpl implements StudentRepository {
  /// Creates the repository.
  StudentRepositoryImpl({
    required this._remoteDataSource,
    StudentImportValidator? importValidator,
  }) : _importValidator = importValidator ?? const StudentImportValidator();

  final StudentRemoteDataSource _remoteDataSource;
  final StudentImportValidator _importValidator;

  @override
  Stream<List<Student>> watchStudents(String branchId, String batchId) {
    return _remoteDataSource.watchStudents(branchId, batchId);
  }

  @override
  Future<Result<List<Student>>> listStudents(
    String branchId,
    String batchId,
  ) async {
    try {
      final students = await _remoteDataSource.listStudents(branchId, batchId);
      return Success<List<Student>>(students);
    } on Object catch (error, stackTrace) {
      return Err<List<Student>>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<Student>> getStudent(
    String branchId,
    String batchId,
    String studentId,
  ) async {
    try {
      final student = await _remoteDataSource.getStudent(
        branchId,
        batchId,
        studentId,
      );
      return Success<Student>(student);
    } on Object catch (error, stackTrace) {
      return Err<Student>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<Student>> createStudent(
    String branchId,
    String batchId,
    StudentDraft draft,
  ) async {
    try {
      final student = await _remoteDataSource.createStudent(
        branchId,
        batchId,
        draft,
      );
      return Success<Student>(student);
    } on Object catch (error, stackTrace) {
      return Err<Student>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<Student>> updateStudent(
    String branchId,
    String batchId,
    String studentId,
    StudentDraft draft,
  ) async {
    try {
      final student = await _remoteDataSource.updateStudent(
        branchId,
        batchId,
        studentId,
        draft,
      );
      return Success<Student>(student);
    } on Object catch (error, stackTrace) {
      return Err<Student>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> setStudentActive(
    String branchId,
    String batchId,
    String studentId, {
    required bool isActive,
  }) async {
    try {
      await _remoteDataSource.setStudentActive(
        branchId,
        batchId,
        studentId,
        isActive: isActive,
      );
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return Err<void>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> deleteStudent(
    String branchId,
    String batchId,
    String studentId,
  ) async {
    try {
      await _remoteDataSource.deleteStudent(
        branchId,
        batchId,
        studentId,
      );
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return Err<void>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<bool>> hasDuplicateStudent({
    required String branchId,
    required String batchId,
    required String fullName,
    required String whatsappNumber,
    String? excludeStudentId,
  }) async {
    try {
      final duplicate = await _remoteDataSource.hasDuplicateStudent(
        branchId: branchId,
        batchId: batchId,
        fullName: fullName,
        whatsappNumber: whatsappNumber,
        excludeStudentId: excludeStudentId,
      );
      return Success<bool>(duplicate);
    } on Object catch (error, stackTrace) {
      return Err<bool>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<ImportPreviewRow>>> parseImportPreview({
    required String branchId,
    required String batchId,
    required int defaultFee,
    required List<int> fileBytes,
  }) async {
    try {
      final rows = await compute(parseExcelWorkbookBytes, fileBytes);
      final existingResult = await listStudents(branchId, batchId);
      switch (existingResult) {
        case Success(:final value):
          final preview = _importValidator.validateRows(
            rows: rows,
            defaultFee: defaultFee,
            existingStudents: value,
          );
          return Success<List<ImportPreviewRow>>(preview);
        case Err(:final failure):
          return Err<List<ImportPreviewRow>>(failure);
      }
    } on Object catch (error, stackTrace) {
      return Err<List<ImportPreviewRow>>(
        ExceptionMapper.map(error, stackTrace),
      );
    }
  }

  @override
  Future<Result<ImportStudentsResult>> importStudents({
    required String branchId,
    required String batchId,
    required List<StudentDraft> drafts,
  }) async {
    try {
      final result = await _remoteDataSource.importStudents(
        branchId: branchId,
        batchId: batchId,
        drafts: drafts,
      );
      return Success<ImportStudentsResult>(result);
    } on Object catch (error, stackTrace) {
      return Err<ImportStudentsResult>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<int>>> buildSampleTemplateBytes() async {
    try {
      final bytes = buildSampleStudentTemplateBytes();
      return Success<List<int>>(bytes);
    } on Object catch (error, stackTrace) {
      return Err<List<int>>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<List<StudentPaymentSummary>>> getPaymentHistory(
    String branchId,
    String batchId,
    String studentId,
  ) async {
    try {
      final history = await _remoteDataSource.getPaymentHistory(
        branchId,
        batchId,
        studentId,
      );
      return Success<List<StudentPaymentSummary>>(history);
    } on Object catch (error, stackTrace) {
      return Err<List<StudentPaymentSummary>>(
        ExceptionMapper.map(error, stackTrace),
      );
    }
  }
}

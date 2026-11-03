import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/students/domain/entities/import_preview_row.dart';
import 'package:feemanager/features/students/domain/entities/student_draft.dart';
import 'package:feemanager/features/students/domain/usecases/student_import_usecases.dart';
import 'package:feemanager/features/students/presentation/cubit/import_students_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Excel pick, preview, and import flow.
class ImportStudentsCubit extends Cubit<ImportStudentsState> {
  /// Creates the cubit.
  ImportStudentsCubit({
    required this._parseImport,
    required this._importStudents,
    required this._buildTemplate,
  }) : super(
         const ImportStudentsIdle(
           branchId: '',
           batchId: '',
           defaultFee: 0,
         ),
       );

  final ParseStudentImport _parseImport;
  final ImportStudents _importStudents;
  final BuildStudentTemplate _buildTemplate;

  /// Starts the flow for a batch.
  void started({
    required String branchId,
    required String batchId,
    required int defaultFee,
  }) {
    emit(
      ImportStudentsIdle(
        branchId: branchId,
        batchId: batchId,
        defaultFee: defaultFee,
      ),
    );
  }

  /// Changes the preview filter chip.
  void filterChanged(ImportPreviewFilter filter) {
    final current = state;
    if (current is ImportStudentsPreview) {
      emit(current.copyWith(filter: filter));
    }
  }

  /// Parses selected file bytes.
  Future<void> parseFile(List<int> bytes) async {
    final current = state;
    if (current is! ImportStudentsIdle) {
      return;
    }
    emit(const ImportStudentsParsing());
    final result = await _parseImport(
      ParseStudentImportParams(
        branchId: current.branchId,
        batchId: current.batchId,
        defaultFee: current.defaultFee,
        fileBytes: bytes,
      ),
    );
    switch (result) {
      case Success(:final value):
        emit(
          ImportStudentsPreview(
            rows: value,
            filter: ImportPreviewFilter.valid,
            branchId: current.branchId,
            batchId: current.batchId,
          ),
        );
      case Err(:final failure):
        emit(ImportStudentsFailure(failure.message));
    }
  }

  /// Imports valid and warning rows.
  Future<void> confirmImport() async {
    final current = state;
    if (current is! ImportStudentsPreview) {
      return;
    }
    final drafts = current.rows
        .where(
          (row) =>
              row.category == ImportRowCategory.valid ||
              row.category == ImportRowCategory.warning,
        )
        .map((row) => row.draft)
        .whereType<StudentDraft>()
        .toList();
    if (drafts.isEmpty) {
      emit(const ImportStudentsFailure(AppStrings.importNoValidRows));
      return;
    }
    const chunkSize = 400;
    final totalChunks = (drafts.length / chunkSize).ceil();
    emit(const ImportStudentsRunning(0, 1));
    final result = await _importStudents(
      ImportStudentsParams(
        branchId: current.branchId,
        batchId: current.batchId,
        drafts: drafts,
      ),
    );
    switch (result) {
      case Success(:final value):
        emit(ImportStudentsComplete(value));
      case Err(:final failure):
        emit(ImportStudentsFailure(failure.message));
    }
    if (totalChunks > 1) {
      // Progress is coarse until chunked import reports per chunk.
    }
  }

  /// Returns sample template bytes for sharing.
  Future<Result<List<int>>> downloadTemplate() {
    return _buildTemplate(const NoParams());
  }
}

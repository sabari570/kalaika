import 'dart:async';
import 'dart:io';

import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/gradient_button.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
import 'package:feemanager/core/widgets/kalaika_screen_body.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:feemanager/features/students/domain/entities/import_preview_row.dart';
import 'package:feemanager/features/students/presentation/cubit/import_students_cubit.dart';
import 'package:feemanager/features/students/presentation/cubit/import_students_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Excel import pick, preview, and confirm flow.
class ImportStudentsPage extends StatelessWidget {
  /// Creates the import screen.
  const ImportStudentsPage({super.key});

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['xlsx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !context.mounted) {
      return;
    }
    final name = result.files.single.name.toLowerCase();
    if (name.endsWith('.xls') && !name.endsWith('.xlsx')) {
      AppSnackBar.showError(context, AppStrings.importXlsNotSupported);
      return;
    }
    var bytes = result.files.single.bytes;
    if (bytes == null) {
      final path = result.files.single.path;
      if (path == null) {
        if (context.mounted) {
          AppSnackBar.showError(context, AppStrings.unknownError);
        }
        return;
      }
      bytes = await File(path).readAsBytes();
    }
    if (!context.mounted) {
      return;
    }
    await context.read<ImportStudentsCubit>().parseFile(bytes);
  }

  Future<void> _shareTemplate(BuildContext context) async {
    final cubit = context.read<ImportStudentsCubit>();
    final result = await cubit.downloadTemplate();
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case Success(:final value):
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/kalaika_students_template.xlsx';
        final file = File(path);
        await file.writeAsBytes(value);
        await SharePlus.instance.share(
          ShareParams(files: <XFile>[XFile(path)]),
        );
      case Err(:final failure):
        AppSnackBar.showError(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.importStudentsTitle)),
      body: KalaikaScreenBody(
        child: BlocConsumer<ImportStudentsCubit, ImportStudentsState>(
        listener: (context, state) {
          if (state is ImportStudentsFailure) {
            AppSnackBar.showError(context, state.message);
          }
          if (state is ImportStudentsComplete) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppStrings.importSummaryImported}: '
                  '${state.result.imported}. '
                  '${AppStrings.importSummarySkipped}: '
                  '${state.result.skipped}. '
                  '${AppStrings.importSummaryFailed}: '
                  '${state.result.failed}.',
                ),
              ),
            );
            context.pop();
          }
        },
        builder: (context, state) {
          return switch (state) {
            ImportStudentsParsing() => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  KalaikaProgressIndicator(
                    size: KalaikaProgressSize.large,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(AppStrings.importParsing),
                ],
              ),
            ),
            ImportStudentsPreview(:final rows, :final filter) =>
              _PreviewBody(
                rows: rows,
                filter: filter,
                onFilterChanged:
                    context.read<ImportStudentsCubit>().filterChanged,
              ),
            ImportStudentsRunning() => const Center(
              child: Text(AppStrings.importInProgress),
            ),
            _ => Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  GradientButton(
                    label: AppStrings.pickExcelFile,
                    onPressed: () => unawaited(_pickFile(context)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedCopperButton(
                    label: AppStrings.downloadSampleTemplate,
                    onPressed: () => unawaited(_shareTemplate(context)),
                  ),
                ],
              ),
            ),
          };
        },
        ),
      ),
    );
  }
}

class _PreviewBody extends StatelessWidget {
  const _PreviewBody({
    required this.rows,
    required this.filter,
    required this.onFilterChanged,
  });

  final List<ImportPreviewRow> rows;
  final ImportPreviewFilter filter;
  final ValueChanged<ImportPreviewFilter> onFilterChanged;

  List<ImportPreviewRow> get _filtered {
    return rows.where((row) {
      return switch (filter) {
        ImportPreviewFilter.valid =>
          row.category == ImportRowCategory.valid,
        ImportPreviewFilter.warnings =>
          row.category == ImportRowCategory.warning,
        ImportPreviewFilter.needsCorrection =>
          row.category == ImportRowCategory.needsCorrection,
        ImportPreviewFilter.duplicates =>
          row.category == ImportRowCategory.duplicate,
      };
    }).toList();
  }

  int _count(ImportRowCategory category) {
    return rows.where((row) => row.category == category).length;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Column(
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              _FilterChip(
                label: '${AppStrings.importFilterValid} '
                    '(${_count(ImportRowCategory.valid)})',
                selected: filter == ImportPreviewFilter.valid,
                onSelected: () => onFilterChanged(ImportPreviewFilter.valid),
              ),
              _FilterChip(
                label:
                    '${AppStrings.importFilterWarnings} '
                    '(${_count(ImportRowCategory.warning)})',
                selected: filter == ImportPreviewFilter.warnings,
                onSelected: () =>
                    onFilterChanged(ImportPreviewFilter.warnings),
              ),
              _FilterChip(
                label:
                    '${AppStrings.importFilterCorrection} '
                    '(${_count(ImportRowCategory.needsCorrection)})',
                selected: filter == ImportPreviewFilter.needsCorrection,
                onSelected: () => onFilterChanged(
                  ImportPreviewFilter.needsCorrection,
                ),
              ),
              _FilterChip(
                label:
                    '${AppStrings.importFilterDuplicates} '
                    '(${_count(ImportRowCategory.duplicate)})',
                selected: filter == ImportPreviewFilter.duplicates,
                onSelected: () =>
                    onFilterChanged(ImportPreviewFilter.duplicates),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final row = filtered[index];
              return ListTile(
                title: Text(
                  row.draft?.fullName ?? 'Row ${row.rowNumber}',
                ),
                subtitle: Text(row.messages.join(' ')),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: GradientButton(
            label: AppStrings.importConfirm,
            onPressed: () => unawaited(
              context.read<ImportStudentsCubit>().confirmImport(),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

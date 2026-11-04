import 'dart:io';

import 'package:excel/excel.dart';
import 'package:feemanager/features/students/data/services/excel_workbook_parser.dart';
import 'package:feemanager/features/students/data/services/student_import_validator.dart';
import 'package:feemanager/features/students/domain/entities/import_preview_row.dart';

void main() {
  final bytes = File(
    '/home/sabarikrishnar/Downloads/KALAIKA OFFICIAL LATEST 1.xlsx',
  ).readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);
  final sheet = excel.tables.values.first;
  print('sheet.rows.length=${sheet.rows.length} maxRows=${sheet.maxRows}');
  final rows = parseExcelWorkbookBytes(bytes);
  print('row count ${rows.length}');
  for (var i = 23; i < 30 && i < sheet.rows.length; i++) {
    final row = sheet.rows[i];
    print('raw row $i len=${row.length} cells=${row.take(3).map((c)=>c?.value).toList()}');
  }
  for (var i = 0; i < 3; i++) {
    final row = sheet.rows[i];
    print(
      'sheet row $i: ${row.map((c) => '${c?.value}(${c?.value.runtimeType})').toList()}',
    );
  }
  if (rows.isNotEmpty) {
    print('keys row1: ${rows[0].keys.toList()}');
    print('row1: ${rows[0]}');
    if (rows.length > 1) {
      print('row2: ${rows[1]}');
    }
  }
  const validator = StudentImportValidator();
  final preview = validator.validateRows(
    rows: rows,
    defaultFee: 500,
    existingStudents: const [],
  );
  final valid = preview.where((r) => r.category == ImportRowCategory.valid).length;
  final warn = preview.where((r) => r.category == ImportRowCategory.warning).length;
  final bad = preview.where((r) => r.category == ImportRowCategory.needsCorrection).length;
  print('valid=$valid warn=$warn bad=$bad');
  final firstBad = preview.firstWhere(
    (r) => r.category == ImportRowCategory.needsCorrection,
  );
  print('first bad row ${firstBad.rowNumber}: ${firstBad.messages}');
}

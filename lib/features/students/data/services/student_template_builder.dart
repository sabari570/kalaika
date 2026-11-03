import 'package:excel/excel.dart';

/// Builds the sample student import workbook bytes.
List<int> buildSampleStudentTemplateBytes() {
  final excel = Excel.createExcel();
  final sheetName = excel.getDefaultSheet();
  final sheet = excel[sheetName ?? 'Sheet1'];
  const headers = <String>[
    'Full Name',
    'Phone Number',
    'WhatsApp Number',
    'Date of Birth',
    'Age',
    'Guardian',
    'Guardian Phone Number',
    'Address',
  ];
  for (var c = 0; c < headers.length; c++) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0))
        .value = TextCellValue(headers[c]);
  }
  sheet
      .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
      .value = TextCellValue('Sample Student');
  sheet
      .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1))
      .value = TextCellValue('9074283081');
  return excel.encode() ?? <int>[];
}

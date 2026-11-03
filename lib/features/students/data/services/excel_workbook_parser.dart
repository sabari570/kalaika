import 'package:excel/excel.dart';

/// Raw cell values keyed by normalized header name.
typedef ExcelRowMap = Map<String, String>;

/// Parses the first sheet of an `.xlsx` workbook.
List<ExcelRowMap> parseExcelWorkbookBytes(List<int> bytes) {
  final excel = Excel.decodeBytes(bytes);
  if (excel.tables.isEmpty) {
    return <ExcelRowMap>[];
  }
  final sheet = excel.tables.values.first;
  if (sheet.rows.isEmpty) {
    return <ExcelRowMap>[];
  }
  var headerIndex = -1;
  var headers = <String>[];
  for (var i = 0; i < sheet.rows.length; i++) {
    final row = sheet.rows[i];
    if (row.isEmpty) {
      continue;
    }
    final values = row
        .map((cell) => _cellText(cell?.value))
        .map((value) => value.trim())
        .toList();
    if (values.every((value) => value.isEmpty)) {
      continue;
    }
    headerIndex = i;
    headers = values.map(_normalizeHeader).toList();
    break;
  }
  if (headerIndex < 0) {
    return <ExcelRowMap>[];
  }
  final rows = <ExcelRowMap>[];
  for (var i = headerIndex + 1; i < sheet.rows.length; i++) {
    if (rows.length >= 1000) {
      break;
    }
    final row = sheet.rows[i];
    final map = <String, String>{};
    var hasContent = false;
    for (var c = 0; c < headers.length; c++) {
      final header = headers[c];
      if (header.isEmpty) {
        continue;
      }
      final text = c < row.length ? _cellText(row[c]?.value) : '';
      if (text.trim().isNotEmpty) {
        hasContent = true;
      }
      map[header] = text.trim();
    }
    if (hasContent) {
      rows.add(map);
    }
  }
  return rows;
}

String _normalizeHeader(String raw) {
  final collapsed = raw.trim().toLowerCase().replaceAll(
    RegExp(r'\s+'),
    ' ',
  );
  return switch (collapsed) {
    'full name' || 'name' || 'student name' => 'fullName',
    'phone' || 'phone no' || 'phone number' || 'mobile' => 'phone',
    'whatsapp' || 'whatsapp no' || 'whatsapp number' => 'whatsapp',
    'dob' || 'date of birth' => 'dob',
    'age' => 'age',
    'guardian' || 'guardian name' || 'parent' => 'guardian',
    'guardian phone' || 'guardian phone number' || 'guardian contact' =>
      'guardianPhone',
    'address' => 'address',
    _ => collapsed,
  };
}

String _cellText(Object? value) {
  if (value == null) {
    return '';
  }
  if (value is DateTime) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }
  return value.toString();
}

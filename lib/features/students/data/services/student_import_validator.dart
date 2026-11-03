import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/utils/age_utils.dart';
import 'package:feemanager/core/utils/phone_utils.dart';
import 'package:feemanager/features/students/data/services/excel_workbook_parser.dart';
import 'package:feemanager/features/students/domain/entities/import_preview_row.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:feemanager/features/students/domain/entities/student_draft.dart';
import 'package:intl/intl.dart';

/// Validates parsed Excel rows for student import.
class StudentImportValidator {
  /// Creates the validator.
  const StudentImportValidator();

  /// Builds preview rows using [existingStudents] for duplicate checks.
  List<ImportPreviewRow> validateRows({
    required List<ExcelRowMap> rows,
    required int defaultFee,
    required List<Student> existingStudents,
  }) {
    final existingKeys = existingStudents
        .map(
          (student) => _duplicateKey(
            student.fullName,
            student.whatsappNumber,
          ),
        )
        .toSet();
    final fileKeys = <String>{};
    final preview = <ImportPreviewRow>[];
    for (var i = 0; i < rows.length; i++) {
      final rowNumber = i + 2;
      final row = rows[i];
      final messages = <String>[];
      var category = ImportRowCategory.valid;

      final fullName = row['fullName']?.trim() ?? '';
      if (fullName.isEmpty) {
        messages.add(AppStrings.importNameRequired);
        category = ImportRowCategory.needsCorrection;
      }

      final phoneRaw = row['phone'] ?? '';
      String? phoneDigits;
      if (phoneRaw.isNotEmpty) {
        final phoneResult = PhoneUtils.normalize(
          phoneRaw,
          bulkImport: true,
        );
        switch (phoneResult) {
          case PhoneNormalized(:final digits):
            phoneDigits = digits;
          case PhoneInvalid(:final message):
            messages.add(message);
            category = ImportRowCategory.needsCorrection;
          case PhoneNeedsCorrection(:final message):
            messages.add(message);
            category = ImportRowCategory.needsCorrection;
          case PhoneNeedsConfirmation():
            messages.add(AppStrings.phoneNeedsCorrection);
            category = ImportRowCategory.needsCorrection;
        }
      }

      var whatsappRaw = row['whatsapp'] ?? '';
      if (whatsappRaw.isEmpty && phoneDigits != null) {
        whatsappRaw = phoneRaw;
        messages.add(AppStrings.importWhatsappFromPhone);
        if (category == ImportRowCategory.valid) {
          category = ImportRowCategory.warning;
        }
      }
      String? whatsappDigits;
      if (whatsappRaw.isEmpty) {
        messages.add(AppStrings.importWhatsappRequired);
        category = ImportRowCategory.needsCorrection;
      } else {
        final waResult = PhoneUtils.normalize(
          whatsappRaw,
          bulkImport: true,
        );
        switch (waResult) {
          case PhoneNormalized(:final digits):
            whatsappDigits = digits;
          case PhoneInvalid(:final message):
            messages.add(message);
            category = ImportRowCategory.needsCorrection;
          case PhoneNeedsCorrection(:final message):
            messages.add(message);
            category = ImportRowCategory.needsCorrection;
          case PhoneNeedsConfirmation():
            messages.add(AppStrings.phoneNeedsCorrection);
            category = ImportRowCategory.needsCorrection;
        }
      }

      DateTime? dob;
      final dobText = row['dob'] ?? '';
      if (dobText.isNotEmpty) {
        final parsed = _parseDateOfBirth(dobText);
        if (parsed == null) {
          messages.add(AppStrings.importDobInvalid);
          category = ImportRowCategory.needsCorrection;
        } else {
          dob = parsed;
        }
      }

      int? age;
      if (dob != null) {
        age = AgeUtils.ageFromDateOfBirth(dob);
      } else {
        final ageText = row['age'] ?? '';
        if (ageText.isNotEmpty) {
          final parsedAge = int.tryParse(ageText.trim());
          if (parsedAge == null ||
              !AgeUtils.isValidManualAge(parsedAge)) {
            messages.add(AppStrings.importAgeInvalid);
            category = ImportRowCategory.needsCorrection;
          } else {
            age = parsedAge;
          }
        }
      }

      String? guardianPhone;
      final guardianPhoneRaw = row['guardianPhone'] ?? '';
      if (guardianPhoneRaw.isNotEmpty) {
        final gpResult = PhoneUtils.normalize(
          guardianPhoneRaw,
          bulkImport: true,
        );
        switch (gpResult) {
          case PhoneNormalized(:final digits):
            guardianPhone = digits;
          case PhoneInvalid():
          case PhoneNeedsCorrection():
          case PhoneNeedsConfirmation():
            messages.add(AppStrings.importGuardianPhoneDropped);
            if (category == ImportRowCategory.valid) {
              category = ImportRowCategory.warning;
            }
        }
      }

      StudentDraft? draft;
      if (whatsappDigits != null && fullName.isNotEmpty) {
        draft = StudentDraft(
          fullName: fullName,
          phoneNumber: phoneDigits,
          whatsappNumber: whatsappDigits,
          dateOfBirth: dob,
          age: age,
          guardianName: _nullable(row['guardian']),
          guardianPhone: guardianPhone,
          address: _nullable(row['address']),
          monthlyFee: defaultFee,
        );
        final key = _duplicateKey(fullName, whatsappDigits);
        if (fileKeys.contains(key)) {
          messages.add(AppStrings.importDuplicateInFile);
          category = ImportRowCategory.duplicate;
        } else if (existingKeys.contains(key)) {
          messages.add(AppStrings.importDuplicateExisting);
          category = ImportRowCategory.duplicate;
        } else {
          fileKeys.add(key);
        }
      }

      preview.add(
        ImportPreviewRow(
          rowNumber: rowNumber,
          category: category,
          messages: messages,
          draft: category == ImportRowCategory.valid ||
                  category == ImportRowCategory.warning
              ? draft
              : null,
        ),
      );
    }
    return preview;
  }

  String _duplicateKey(String name, String whatsapp) {
    return '${name.trim().toLowerCase()}|$whatsapp';
  }

  String? _nullable(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  DateTime? _parseDateOfBirth(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final formats = <DateFormat>[
      DateFormat('dd/MM/yyyy'),
      DateFormat('dd-MM-yyyy'),
      DateFormat('yyyy-MM-dd'),
    ];
    for (final format in formats) {
      try {
        return format.parseStrict(trimmed);
      } on FormatException {
        continue;
      }
    }
    return null;
  }
}

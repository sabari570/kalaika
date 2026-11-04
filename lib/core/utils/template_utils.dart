import 'package:feemanager/features/fees/domain/entities/institute_settings.dart';

/// WhatsApp and receipt message template helpers.
abstract final class TemplateUtils {
  /// Replaces `{key}` placeholders with values from [replacements].
  static String apply(String template, Map<String, String> replacements) {
    var result = template;
    for (final entry in replacements.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }

  /// Sample values for the settings template preview.
  static Map<String, String> previewReplacements({
    required InstituteSettings institute,
  }) {
    return <String, String>{
      'recipient_name': 'Guardian Name',
      'guardian_name': 'Guardian Name',
      'student_name': 'Student Name',
      'amount': '1,200',
      'batch_fee': '1,200',
      'month': 'October',
      'year': '2026',
      'batch_name': 'Batch Name',
      'branch_name': 'Branch Name',
      'receipt_no': 'KLK-2026-000001',
      'receipt_url': '—',
      'institute_name': institute.name,
    };
  }
}

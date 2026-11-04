import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/features/fees/domain/entities/institute_settings.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:intl/intl.dart';

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

  /// Placeholders for a recorded payment share message.
  static Map<String, String> receiptReplacements({
    required Student student,
    required InstituteSettings institute,
    required String branchName,
    required String batchName,
    required String monthKey,
    required int amount,
    required int batchFee,
    required String receiptNo,
  }) {
    final parts = monthKey.split('-');
    final yearPart = parts.isNotEmpty ? parts.first : '';
    final monthPart = parts.length > 1 ? parts[1] : '1';
    final monthDate = DateTime(
      int.parse(yearPart),
      int.parse(monthPart),
    );
    final monthName = DateFormat('MMMM').format(monthDate);
    final guardian = student.guardianName?.trim() ?? '';
    final recipient =
        guardian.isNotEmpty ? guardian : student.fullName;
    final amountText = NumberFormat.decimalPattern().format(amount);
    final batchFeeText = NumberFormat.decimalPattern().format(batchFee);

    return <String, String>{
      'recipient_name': recipient,
      'guardian_name': guardian.isNotEmpty ? guardian : recipient,
      'student_name': student.fullName,
      'amount': amountText,
      'batch_fee': batchFeeText,
      'month': monthName,
      'year': yearPart,
      'batch_name': batchName,
      'branch_name': branchName,
      'receipt_no': receiptNo,
      'receipt_url': AppStrings.receiptAttachedWithMessage,
      'institute_name': institute.name,
    };
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
      'receipt_url': AppStrings.receiptAttachedWithMessage,
      'institute_name': institute.name,
    };
  }
}

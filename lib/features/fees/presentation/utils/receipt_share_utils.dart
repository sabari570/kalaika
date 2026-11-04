import 'dart:io';

import 'package:feemanager/core/constants/app_strings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Writes receipt PDF bytes to a temp file and opens the system share sheet.
abstract final class ReceiptShareUtils {
  /// Shares [pdfBytes] as a PDF file with optional [text].
  static Future<void> sharePdf({
    required List<int> pdfBytes,
    required String receiptNo,
    String? text,
  }) async {
    final directory = await getTemporaryDirectory();
    final safeName = receiptNo.replaceAll('/', '-');
    final file = File('${directory.path}/$safeName.pdf');
    await file.writeAsBytes(pdfBytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path, mimeType: 'application/pdf')],
        text: text,
        subject: AppStrings.feeReceiptShareSubject,
      ),
    );
  }
}

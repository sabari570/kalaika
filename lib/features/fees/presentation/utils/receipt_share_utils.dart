import 'dart:io';

import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/utils/whatsapp_share_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Writes receipt PDF bytes to a temp file and shares them.
abstract final class ReceiptShareUtils {
  /// Writes [pdfBytes] to a temp PDF file and returns its path.
  static Future<String> writePdfToTempFile({
    required List<int> pdfBytes,
    required String receiptNo,
  }) async {
    final directory = await getTemporaryDirectory();
    final safeName = receiptNo.replaceAll('/', '-');
    final file = File('${directory.path}/$safeName.pdf');
    await file.writeAsBytes(pdfBytes, flush: true);
    return file.path;
  }

  /// Shares a PDF file via the system share sheet with optional [text].
  static Future<void> sharePdfFile({
    required String pdfPath,
    required String receiptNo,
    String? text,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[
          XFile(pdfPath, mimeType: 'application/pdf'),
        ],
        text: text,
        subject: AppStrings.feeReceiptShareSubject,
      ),
    );
  }

  /// Shares [pdfBytes] as a PDF file with optional [text].
  static Future<void> sharePdf({
    required List<int> pdfBytes,
    required String receiptNo,
    String? text,
  }) async {
    final path = await writePdfToTempFile(
      pdfBytes: pdfBytes,
      receiptNo: receiptNo,
    );
    await sharePdfFile(
      pdfPath: path,
      receiptNo: receiptNo,
      text: text,
    );
  }

  /// Opens WhatsApp for [phoneDigits] with the PDF and optional [text].
  static Future<bool> sharePdfToWhatsApp({
    required List<int> pdfBytes,
    required String receiptNo,
    required String phoneDigits,
    String? text,
  }) async {
    if (!Platform.isAndroid) {
      return false;
    }
    if (!await WhatsAppShareUtils.isWhatsAppInstalled()) {
      return false;
    }
    final path = await writePdfToTempFile(
      pdfBytes: pdfBytes,
      receiptNo: receiptNo,
    );
    return WhatsAppShareUtils.sharePdfToChat(
      pdfPath: path,
      phoneDigits: phoneDigits,
      text: text,
    );
  }

  /// Opens WhatsApp so the user can pick a chat; PDF and [text] are attached.
  static Future<bool> sharePdfViaWhatsAppPicker({
    required List<int> pdfBytes,
    required String receiptNo,
    String? text,
  }) async {
    if (!Platform.isAndroid) {
      return false;
    }
    if (!await WhatsAppShareUtils.isWhatsAppInstalled()) {
      return false;
    }
    final path = await writePdfToTempFile(
      pdfBytes: pdfBytes,
      receiptNo: receiptNo,
    );
    return WhatsAppShareUtils.sharePdfToWhatsAppApp(
      pdfPath: path,
      text: text,
    );
  }
}

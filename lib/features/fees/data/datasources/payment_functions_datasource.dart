import 'package:cloud_functions/cloud_functions.dart';
import 'package:feemanager/core/constants/cloud_functions_config.dart';
import 'package:feemanager/features/fees/domain/entities/generate_receipt_result.dart';

/// Cloud Functions access for fee payments.
class PaymentFunctionsDataSource {
  /// Creates the data source.
  PaymentFunctionsDataSource({FirebaseFunctions? functions})
    : _functions =
          functions ??
          FirebaseFunctions.instanceFor(
            region: CloudFunctionsConfig.region,
          );

  final FirebaseFunctions _functions;

  /// Invokes [generateReceipt] for the signed-in user.
  Future<GenerateReceiptResult> generateReceipt({
    required String branchId,
    required String batchId,
    required String studentId,
    required String monthKey,
    required int amount,
    required String mode,
    required DateTime paidOn,
    String? note,
  }) async {
    final callable = _functions.httpsCallable(
      CloudFunctionsConfig.generateReceipt,
    );
    final payload = <String, Object?>{
      'branchId': branchId,
      'batchId': batchId,
      'studentId': studentId,
      'month': monthKey,
      'amount': amount,
      'mode': mode,
      'paidOn': paidOn.toUtc().toIso8601String(),
      'note': ?note,
    };
    final response = await callable.call<Map<String, dynamic>>(payload);
    final data = response.data;
    return GenerateReceiptResult(
      receiptNo: _readString(data, 'receiptNo'),
      receiptUrl: _readString(data, 'receiptUrl'),
      status: _readString(data, 'status'),
    );
  }

  static String _readString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! String) {
      throw FormatException('Callable response missing $key.');
    }
    return value;
  }
}

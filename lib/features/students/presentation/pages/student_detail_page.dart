import 'dart:async';

import 'package:feemanager/core/constants/app_routes.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/utils/age_utils.dart';
import 'package:feemanager/core/utils/phone_utils.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/kalaika_card.dart';
import 'package:feemanager/core/widgets/status_chip.dart';
import 'package:feemanager/features/fees/domain/usecases/payment_receipt_actions.dart';
import 'package:feemanager/features/fees/presentation/utils/receipt_share_utils.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:feemanager/features/students/domain/entities/student_payment_summary.dart';
import 'package:feemanager/features/students/presentation/cubit/student_detail_cubit.dart';
import 'package:feemanager/features/students/presentation/cubit/student_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Student profile and payment history.
class StudentDetailPage extends StatelessWidget {
  /// Creates the student detail screen.
  const StudentDetailPage({
    required this.branchId,
    required this.batchId,
    required this.studentId,
    super.key,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Student id.
  final String studentId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentDetailCubit, StudentDetailState>(
      builder: (context, state) {
        return switch (state) {
          StudentDetailLoading() => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          StudentDetailFailure(:final message) => Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(message)),
          ),
          StudentDetailLoaded(:final student, :final payments) =>
            _StudentDetailBody(
              student: student,
              payments: payments,
              branchId: branchId,
              batchId: batchId,
              studentId: studentId,
            ),
        };
      },
    );
  }
}

class _StudentDetailBody extends StatelessWidget {
  const _StudentDetailBody({
    required this.student,
    required this.payments,
    required this.branchId,
    required this.batchId,
    required this.studentId,
  });

  final Student student;
  final List<StudentPaymentSummary> payments;
  final String branchId;
  final String batchId;
  final String studentId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final dob = student.dateOfBirth;
    final age = dob != null
        ? AgeUtils.ageFromDateOfBirth(dob)
        : student.age;

    return Scaffold(
      appBar: AppBar(
        title: Text(student.fullName),
        actions: <Widget>[
          IconButton(
            tooltip: AppStrings.editStudent,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(
              AppRoutes.studentEditPath(branchId, batchId, studentId),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.lg,
        ),
        children: <Widget>[
          KalaikaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _InfoRow(
                  label: AppStrings.phoneNumber,
                  value: student.phoneNumber == null
                      ? '—'
                      : PhoneUtils.formatForDisplay(student.phoneNumber!),
                  telDigits: student.phoneNumber,
                ),
                _InfoRow(
                  label: AppStrings.whatsappNumber,
                  value: PhoneUtils.formatForDisplay(student.whatsappNumber),
                  telDigits: student.whatsappNumber,
                ),
                _InfoRow(
                  label: AppStrings.dateOfBirth,
                  value: dob == null
                      ? '—'
                      : DateFormat.yMMMd().format(dob),
                ),
                _InfoRow(
                  label: AppStrings.age,
                  value: age?.toString() ?? '—',
                ),
                _InfoRow(
                  label: AppStrings.guardian,
                  value: student.guardianName ?? '—',
                ),
                _InfoRow(
                  label: AppStrings.guardianPhone,
                  value: student.guardianPhone == null
                      ? '—'
                      : PhoneUtils.formatForDisplay(student.guardianPhone!),
                  telDigits: student.guardianPhone,
                ),
                _InfoRow(
                  label: AppStrings.address,
                  value: student.address ?? '—',
                ),
                _InfoRow(
                  label: AppStrings.monthlyFee,
                  value: 'Rs. ${student.monthlyFee}',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(AppStrings.paymentHistory, style: theme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          if (payments.isEmpty)
            Text(
              AppStrings.noPaymentHistory,
              style: theme.bodyLarge?.copyWith(
                color: context.appColors.creamMuted,
              ),
            )
          else
            ...payments.map(
              (payment) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: KalaikaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(payment.month, style: theme.titleSmall),
                      Text('Rs. ${payment.amount} · ${payment.mode}'),
                      if (payment.receiptNo != null)
                        Text('Receipt ${payment.receiptNo}'),
                      const SizedBox(height: AppSpacing.sm),
                      StatusChip(status: _statusFor(payment.status)),
                      if (payment.receiptNo != null &&
                          payment.status !=
                              FirestoreKeys.statusVoided) ...<Widget>[
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: () => unawaited(
                            _openReceipt(context, payment),
                          ),
                          child: const Text(AppStrings.openReceipt),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  FeeDisplayStatus _statusFor(String status) {
    return switch (status) {
      FirestoreKeys.statusSent => FeeDisplayStatus.sent,
      FirestoreKeys.statusPaid => FeeDisplayStatus.pendingSend,
      _ => FeeDisplayStatus.unpaid,
    };
  }

  Future<void> _openReceipt(
    BuildContext context,
    StudentPaymentSummary payment,
  ) async {
    final buildPdf = sl<BuildReceiptPdf>();
    final result = await buildPdf(
      BuildReceiptPdfParams(
        branchId: branchId,
        batchId: batchId,
        paymentId: payment.id,
        student: student,
      ),
    );
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case Success(:final value):
        await ReceiptShareUtils.sharePdf(
          pdfBytes: value,
          receiptNo: payment.receiptNo ?? payment.id,
        );
      case Err(:final failure):
        AppSnackBar.showError(context, failure.message);
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.telDigits,
  });

  final String label;
  final String value;
  final String? telDigits;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.appColors.creamMuted,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
          if (telDigits != null)
            TextButton(
              onPressed: () => unawaited(
                launchUrl(Uri.parse('tel:$telDigits')),
              ),
              child: const Text(AppStrings.call),
            ),
        ],
      ),
    );
  }
}

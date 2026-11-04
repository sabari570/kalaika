import 'dart:async';

import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/app_text_field.dart';
import 'package:feemanager/core/widgets/blocking_progress_dialog.dart';
import 'package:feemanager/core/widgets/empty_state.dart';
import 'package:feemanager/core/widgets/kalaika_animated_metric.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
import 'package:feemanager/core/widgets/kalaika_skeleton.dart';
import 'package:feemanager/core/widgets/month_selector.dart';
import 'package:feemanager/features/fees/domain/entities/fee_row.dart';
import 'package:feemanager/features/fees/domain/entities/record_payment_result.dart';
import 'package:feemanager/features/fees/presentation/cubit/fee_tracker_cubit.dart';
import 'package:feemanager/features/fees/presentation/cubit/fee_tracker_state.dart';
import 'package:feemanager/features/fees/presentation/utils/receipt_delivery_utils.dart';
import 'package:feemanager/features/fees/presentation/widgets/fee_row_widget.dart';
import 'package:feemanager/features/fees/presentation/widgets/record_payment_confirm_dialog.dart';
import 'package:feemanager/features/fees/presentation/widgets/sent_receipt_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Monthly fee tracker tab for a batch.
class FeeTrackerTab extends StatelessWidget {
  /// Creates the fee tracker tab.
  const FeeTrackerTab({
    required this.branchId,
    required this.batchId,
    required this.batchDefaultFee,
    super.key,
  });

  /// Branch id.
  final String branchId;

  /// Batch id.
  final String batchId;

  /// Batch default fee (shown when recording payment in a later milestone).
  final int batchDefaultFee;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeeTrackerCubit, FeeTrackerState>(
      builder: (context, state) {
        return switch (state) {
          FeeTrackerLoading() => const Center(
            child: KalaikaProgressIndicator(
              size: KalaikaProgressSize.large,
            ),
          ),
          FeeTrackerFailure(:final message) => EmptyState(
            message: message,
            actionLabel: AppStrings.retry,
            onAction: () => context.read<FeeTrackerCubit>().started(
              branchId: branchId,
              batchId: batchId,
            ),
          ),
          FeeTrackerLoaded() => _FeeTrackerBody(
            branchId: branchId,
            batchId: batchId,
            state: state,
            batchDefaultFee: batchDefaultFee,
          ),
        };
      },
    );
  }
}

class _FeeTrackerBody extends StatelessWidget {
  const _FeeTrackerBody({
    required this.branchId,
    required this.batchId,
    required this.state,
    required this.batchDefaultFee,
  });

  final String branchId;
  final String batchId;
  final FeeTrackerLoaded state;
  final int batchDefaultFee;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: MonthSelector(
                  initialMonth: state.selectedMonth,
                  onChanged: context.read<FeeTrackerCubit>().monthChanged,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                  AppSpacing.screenHorizontal,
                  AppSpacing.sm,
                ),
                child: KalaikaAnimatedMetric(
                  value: state.paidCount.toDouble(),
                  builder: (context, paidAnimated) {
                    return KalaikaAnimatedMetric(
                      value: state.collected.toDouble(),
                      builder: (context, collectedAnimated) {
                        final paid = paidAnimated.round();
                        final collected = collectedAnimated.round();
                        final progress = state.totalCount == 0
                            ? 0.0
                            : paid / state.totalCount;
                        final collectedText = NumberFormat.decimalPattern()
                            .format(collected);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              AppStrings.feePaidOfTotal
                                  .replaceFirst('{paid}', '$paid')
                                  .replaceFirst(
                                    '{total}',
                                    '${state.totalCount}',
                                  ),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              AppStrings.feeCollected.replaceFirst(
                                '{amount}',
                                collectedText,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: colors.creamMuted),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: KalaikaAnimatedMetric(
                                value: progress,
                                builder: (context, animatedProgress) {
                                  return LinearProgressIndicator(
                                    value: animatedProgress.clamp(0.0, 1.0),
                                    minHeight: 6,
                                    color: colors.copper,
                                    backgroundColor: colors.surfaceHigh,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: AppTextField(
                  hint: AppStrings.feeSearchHint,
                  onChanged: context.read<FeeTrackerCubit>().searchChanged,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _FilterChips(
                selected: state.filter,
                onChanged: context.read<FeeTrackerCubit>().filterChanged,
              ),
            ],
          ),
        ),
        if (state.paymentsRefreshing)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.sm,
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, index) => const KalaikaListRowSkeleton(),
                childCount: 6,
              ),
            ),
          )
        else if (state.filteredRows.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(message: AppStrings.noMatchingFeeRows),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.sm,
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final row = state.filteredRows[index];
                  return FeeRowWidget(
                    key: ValueKey<String>(
                      '${state.monthKey}-${row.student.id}',
                    ),
                    row: row,
                    onUnpaidTap: () => unawaited(
                      _recordPayment(
                        context,
                        row,
                        state.selectedMonth,
                      ),
                    ),
                    onSendTap: () => unawaited(_shareReceipt(context, row)),
                    onSentTap: () => unawaited(
                      SentReceiptBottomSheet.show(
                        context,
                        row: row,
                        branchId: branchId,
                        batchId: batchId,
                        cubit: context.read<FeeTrackerCubit>(),
                      ),
                    ),
                    onLongPress: () => unawaited(_voidPayment(context, row)),
                  );
                },
                childCount: state.filteredRows.length,
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.viewInsetsOf(context).bottom,
          ),
        ),
      ],
    );
  }

  Future<void> _recordPayment(
    BuildContext context,
    FeeRow row,
    DateTime selectedMonth,
  ) async {
    final form = await RecordPaymentConfirmSheet.show(
      context,
      studentName: row.student.fullName,
      amount: row.amount,
      batchDefaultFee: batchDefaultFee,
      month: selectedMonth,
    );
    if (form == null || !context.mounted) {
      return;
    }
    BlockingProgressDialog.show(
      context,
      message: AppStrings.generatingReceipt,
    );
    final cubit = context.read<FeeTrackerCubit>();
    final result = await cubit.recordPayment(
      row: row,
      amount: form.amount,
      mode: form.mode,
      paidOn: form.paidOn,
      note: form.note,
    );
    if (context.mounted) {
      BlockingProgressDialog.hide(context);
    }
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case Success<RecordPaymentResult>(:final value):
        await ReceiptDeliveryUtils.sharePreparedAndPromptMarkSent(
          context: context,
          row: row,
          cubit: cubit,
          pdfBytes: value.pdfBytes,
          receiptNo: value.receiptNo,
          shareMessage: value.shareMessage,
          promptMarkSent: true,
          treatRowAsPending: true,
          showPreparingDialog: true,
        );
      case Err(:final failure):
        AppSnackBar.showErrorWithAction(
          context,
          message: failure.message,
          actionLabel: AppStrings.retry,
          onAction: () => unawaited(
            _recordPayment(context, row, selectedMonth),
          ),
        );
    }
  }

  Future<void> _shareReceipt(BuildContext context, FeeRow row) async {
    final cubit = context.read<FeeTrackerCubit>();
    await ReceiptDeliveryUtils.loadShareAndPromptMarkSent(
      context: context,
      row: row,
      cubit: cubit,
      promptMarkSent: true,
      loadPayload: () => _loadSharePayload(cubit, row),
    );
  }

  Future<Result<ReceiptSharePayload>> _loadSharePayload(
    FeeTrackerCubit cubit,
    FeeRow row,
  ) async {
    final pdfResult = await cubit.buildReceiptPdfForRow(row);
    final messageResult = await cubit.buildShareMessageForRow(row);
    switch (pdfResult) {
      case Success(:final value):
        final pdfBytes = value;
        switch (messageResult) {
          case Success(:final value):
            return Success(
              (
                pdfBytes: pdfBytes,
                receiptNo: row.payment?.receiptNo ?? 'receipt',
                shareMessage: value,
              ),
            );
          case Err(:final failure):
            return Err(failure);
        }
      case Err(:final failure):
        return Err(failure);
    }
  }

  Future<void> _voidPayment(BuildContext context, FeeRow row) async {
    if (row.displayStatus == FeeRowStatus.unpaid) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.voidPayment),
        content: const Text(AppStrings.voidPaymentConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.voidPayment),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    BlockingProgressDialog.show(context, message: AppStrings.deleting);
    final result =
        await context.read<FeeTrackerCubit>().voidPaymentForRow(row);
    if (context.mounted) {
      BlockingProgressDialog.hide(context);
    }
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case Success<void>():
        break;
      case Err(:final failure):
        AppSnackBar.showError(context, failure.message);
    }
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.onChanged,
  });

  final FeeListFilter selected;
  final ValueChanged<FeeListFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Row(
        children: <Widget>[
          _chip(
            AppStrings.feeFilterAll,
            FeeListFilter.all,
          ),
          _chip(
            AppStrings.statusUnpaid,
            FeeListFilter.unpaid,
          ),
          _chip(
            AppStrings.statusPendingSend,
            FeeListFilter.pendingSend,
          ),
          _chip(
            AppStrings.statusSent,
            FeeListFilter.sent,
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, FeeListFilter value) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: selected == value,
        onSelected: (_) => onChanged(value),
      ),
    );
  }
}

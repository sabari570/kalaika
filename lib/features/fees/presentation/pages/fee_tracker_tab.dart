import 'dart:async';

import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/app_text_field.dart';
import 'package:feemanager/core/widgets/empty_state.dart';
import 'package:feemanager/core/widgets/month_selector.dart';
import 'package:feemanager/features/fees/domain/entities/fee_row.dart';
import 'package:feemanager/features/fees/presentation/cubit/fee_tracker_cubit.dart';
import 'package:feemanager/features/fees/presentation/cubit/fee_tracker_state.dart';
import 'package:feemanager/features/fees/presentation/widgets/fee_row_widget.dart';
import 'package:feemanager/features/fees/presentation/widgets/record_payment_confirm_dialog.dart';
import 'package:flutter/foundation.dart';
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

  /// Batch default fee for debug payments.
  final int batchDefaultFee;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeeTrackerCubit, FeeTrackerState>(
      builder: (context, state) {
        return switch (state) {
          FeeTrackerLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          FeeTrackerFailure(:final message) => EmptyState(
            message: message,
            actionLabel: AppStrings.retry,
            onAction: () => context.read<FeeTrackerCubit>().started(
              branchId: branchId,
              batchId: batchId,
              batchDefaultFee: batchDefaultFee,
            ),
          ),
          FeeTrackerLoaded() => _FeeTrackerBody(
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
    required this.state,
    required this.batchDefaultFee,
  });

  final FeeTrackerLoaded state;
  final int batchDefaultFee;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final progress = state.totalCount == 0
        ? 0.0
        : state.paidCount / state.totalCount;
    final collectedText = NumberFormat.decimalPattern().format(
      state.collected,
    );

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppStrings.feePaidOfTotal
                          .replaceFirst('{paid}', '${state.paidCount}')
                          .replaceFirst('{total}', '${state.totalCount}'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppStrings.feeCollected.replaceFirst(
                        '{amount}',
                        collectedText,
                      ),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.creamMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        color: colors.copper,
                        backgroundColor: colors.surfaceHigh,
                      ),
                    ),
                  ],
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
              if (kDebugMode)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    AppStrings.debugCreatePayment,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.creamMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (state.filteredRows.isEmpty)
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
                    row: row,
                    onUnpaidTap: () => unawaited(
                      _debugPay(
                        context,
                        row,
                        state.selectedMonth,
                      ),
                    ),
                    onSendTap: () {},
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

  Future<void> _debugPay(
    BuildContext context,
    FeeRow row,
    DateTime selectedMonth,
  ) async {
    final confirmed = await RecordPaymentConfirmDialog.show(
      context,
      studentName: row.student.fullName,
      amount: row.amount,
      month: selectedMonth,
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final result = await context.read<FeeTrackerCubit>().debugRecordPayment(
      row,
    );
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

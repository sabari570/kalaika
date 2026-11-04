import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/widgets/empty_state.dart';
import 'package:feemanager/core/widgets/kalaika_card.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
import 'package:feemanager/core/widgets/kalaika_screen_body.dart';
import 'package:feemanager/core/widgets/section_header.dart';
import 'package:feemanager/features/dashboard/domain/entities/pending_receipt_item.dart';
import 'package:feemanager/features/dashboard/presentation/cubit/pending_receipts_cubit.dart';
import 'package:feemanager/features/dashboard/presentation/cubit/pending_receipts_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Lists paid payments whose receipts have not been sent.
class PendingReceiptsPage extends StatelessWidget {
  /// Creates the pending receipts screen.
  const PendingReceiptsPage({
    required this.monthKey,
    super.key,
  });

  /// Selected month key.
  final String monthKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.pendingReceiptsTitle),
      ),
      body: BlocBuilder<PendingReceiptsCubit, PendingReceiptsState>(
        builder: (context, state) {
          return switch (state) {
            PendingReceiptsLoading() => const KalaikaScreenBody(
              child: Center(child: KalaikaProgressIndicator()),
            ),
            PendingReceiptsFailure(:final message) => KalaikaScreenBody(
              child: EmptyState(
                message: message,
                actionLabel: AppStrings.retry,
                onAction: () => context
                    .read<PendingReceiptsCubit>()
                    .started(monthKey),
              ),
            ),
            PendingReceiptsLoaded(:final items) => _PendingReceiptsBody(
              items: items,
            ),
          };
        },
      ),
    );
  }
}

class _PendingReceiptsBody extends StatelessWidget {
  const _PendingReceiptsBody({required this.items});

  final List<PendingReceiptItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const KalaikaScreenBody(
        child: EmptyState(message: AppStrings.pendingReceiptsEmpty),
      );
    }

    final grouped = <String, List<PendingReceiptItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.batchName, () => <PendingReceiptItem>[]).add(
        item,
      );
    }

    return KalaikaScreenBody(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
          AppSpacing.screenHorizontal,
          AppSpacing.xxl,
        ),
        children: <Widget>[
          for (final entry in grouped.entries) ...<Widget>[
            SectionHeader(title: entry.key),
            const SizedBox(height: AppSpacing.sm),
            ...entry.value.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: KalaikaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.studentName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (item.guardianName != null &&
                          item.guardianName!.trim().isNotEmpty)
                        Text(
                          item.guardianName!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: context.appColors.creamMuted,
                              ),
                        ),
                      Text('Rs. ${item.amount}'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

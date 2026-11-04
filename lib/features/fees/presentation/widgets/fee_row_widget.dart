import 'package:feemanager/core/constants/app_durations.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/widgets/status_chip.dart';
import 'package:feemanager/features/fees/domain/entities/fee_row.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// One student row on the fee tracker.
class FeeRowWidget extends StatelessWidget {
  /// Creates a fee tracker row.
  const FeeRowWidget({
    required this.row,
    required this.onUnpaidTap,
    required this.onSendTap,
    this.onSentTap,
    this.onLongPress,
    super.key,
  });

  /// Row view model.
  final FeeRow row;

  /// Invoked when the unpaid control is activated to record payment.
  final VoidCallback onUnpaidTap;

  /// Invoked when send is pressed on a pending row (M7).
  final VoidCallback onSendTap;

  /// Invoked when a sent row is tapped.
  final VoidCallback? onSentTap;

  /// Invoked on long-press to void a recorded payment.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = context.appColors;
    final guardian = row.student.guardianName?.trim() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: GestureDetector(
        onLongPress: onLongPress,
        onTap: row.displayStatus == FeeRowStatus.sent ? onSentTap : null,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: <Widget>[
            _StatusControl(
              status: row.displayStatus,
              sentAt: row.payment?.sentAt,
              onUnpaidTap: onUnpaidTap,
              onSendTap: onSendTap,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(row.student.fullName, style: theme.titleSmall),
                  if (guardian.isNotEmpty)
                    Text(
                      guardian,
                      style: theme.bodySmall?.copyWith(
                        color: colors.creamMuted,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              'Rs. ${row.amount}',
              style: theme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusControl extends StatelessWidget {
  const _StatusControl({
    required this.status,
    required this.sentAt,
    required this.onUnpaidTap,
    required this.onSendTap,
  });

  final FeeRowStatus status;
  final DateTime? sentAt;
  final VoidCallback onUnpaidTap;
  final VoidCallback onSendTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedSwitcher(
      duration: AppDurations.chipSwitch,
      switchInCurve: AppDurations.easeOut,
      switchOutCurve: AppDurations.easeOut,
      child: switch (status) {
        FeeRowStatus.unpaid => Semantics(
          key: const ValueKey<String>('unpaid'),
          label: AppStrings.statusUnpaid,
          button: true,
          child: SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: onUnpaidTap,
              icon: Icon(
                Icons.check_box_outline_blank,
                color: colors.copper,
              ),
            ),
          ),
        ),
        FeeRowStatus.pendingSend => Row(
          key: const ValueKey<String>('pending'),
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.indeterminate_check_box, color: colors.warning),
            IconButton(
              tooltip: AppStrings.sendReceipt,
              onPressed: onSendTap,
              icon: Icon(Icons.send_outlined, color: colors.warning),
            ),
            const StatusChip(status: FeeDisplayStatus.pendingSend),
          ],
        ),
        FeeRowStatus.sent => Row(
          key: const ValueKey<String>('sent'),
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.check_box, color: colors.success),
            const SizedBox(width: AppSpacing.sm),
            StatusChip(
              status: FeeDisplayStatus.sent,
              sentLabel: sentAt == null
                  ? AppStrings.statusSent
                  : AppStrings.statusSentOn.replaceFirst(
                      '{date}',
                      DateFormat('d MMM').format(sentAt!),
                    ),
            ),
          ],
        ),
      },
    );
  }
}

import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/features/batches/presentation/widgets/mode_chip.dart';
import 'package:flutter/material.dart';

/// Header chips for batch detail.
class BatchDetailHeader extends StatelessWidget {
  /// Creates the header row.
  const BatchDetailHeader({
    required this.branchName,
    required this.danceStyle,
    required this.mode,
    super.key,
  });

  /// Branch name line.
  final String branchName;

  /// Dance style label.
  final String danceStyle;

  /// Stored mode value.
  final String mode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(branchName, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              Chip(label: Text(danceStyle)),
              ModeChip(mode: mode),
            ],
          ),
        ],
      ),
    );
  }
}

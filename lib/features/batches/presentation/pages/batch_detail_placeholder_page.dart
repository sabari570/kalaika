import 'package:feemanager/core/constants/app_routes.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/batches/presentation/widgets/mode_chip.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder until M5 fee tracker and student list are implemented.
class BatchDetailPlaceholderPage extends StatelessWidget {
  /// Creates the batch detail placeholder.
  const BatchDetailPlaceholderPage({
    required this.batchName,
    required this.branchName,
    required this.danceStyle,
    required this.mode,
    this.branchId,
    this.batchId,
    super.key,
  });

  /// Builds from a [Batch] entity.
  factory BatchDetailPlaceholderPage.fromBatch(
    Batch batch, {
    String? branchId,
    String? batchId,
  }) {
    return BatchDetailPlaceholderPage(
      batchName: batch.name,
      branchName: batch.branchName,
      danceStyle: batch.danceStyle,
      mode: batch.mode,
      branchId: branchId ?? batch.branchId,
      batchId: batchId ?? batch.id,
    );
  }

  /// Batch display name.
  final String batchName;

  /// Parent branch name.
  final String branchName;

  /// Dance style label.
  final String danceStyle;

  /// Stored mode value.
  final String mode;

  /// Parent branch id for navigation actions.
  final String? branchId;

  /// Batch document id for navigation actions.
  final String? batchId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final canEdit = branchId != null && batchId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(batchName),
        actions: <Widget>[
          if (canEdit)
            IconButton(
              tooltip: AppStrings.editBatch,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(
                AppRoutes.batchEditPath(branchId!, batchId!),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(branchName, style: theme.bodyLarge),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  Chip(label: Text(danceStyle)),
                  ModeChip(mode: mode),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                AppStrings.batchDetailPlaceholder,
                style: theme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

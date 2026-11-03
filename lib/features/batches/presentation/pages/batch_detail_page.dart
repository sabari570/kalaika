import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/batches/domain/usecases/get_batch.dart';
import 'package:feemanager/features/batches/presentation/pages/batch_detail_placeholder_page.dart';
import 'package:flutter/material.dart';

/// Loads a batch and shows the M5 placeholder shell.
class BatchDetailPage extends StatefulWidget {
  /// Creates the batch detail route.
  const BatchDetailPage({
    required this.branchId,
    required this.batchId,
    super.key,
  });

  /// Parent branch id.
  final String branchId;

  /// Batch document id.
  final String batchId;

  @override
  State<BatchDetailPage> createState() => _BatchDetailPageState();
}

class _BatchDetailPageState extends State<BatchDetailPage> {
  late final Future<Result<Batch>> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = sl<GetBatch>()(
      GetBatchParams(
        branchId: widget.branchId,
        batchId: widget.batchId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<Batch>>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return switch (snapshot.data!) {
          Success(:final value) => BatchDetailPlaceholderPage.fromBatch(
            value,
            branchId: widget.branchId,
            batchId: widget.batchId,
          ),
          Err(:final failure) => Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(failure.message)),
          ),
        };
      },
    );
  }
}

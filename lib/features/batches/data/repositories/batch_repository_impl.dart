import 'package:feemanager/core/error/exception_mapper.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/batches/data/datasources/batch_remote_datasource.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/batches/domain/entities/batch_draft.dart';
import 'package:feemanager/features/batches/domain/repositories/batch_repository.dart';

/// Firestore implementation of [BatchRepository].
class BatchRepositoryImpl implements BatchRepository {
  /// Creates the repository.
  BatchRepositoryImpl({required this._remoteDataSource});

  final BatchRemoteDataSource _remoteDataSource;

  @override
  Stream<List<Batch>> watchBatches(String branchId) {
    return _remoteDataSource.watchBatches(branchId);
  }

  @override
  Future<Result<Batch>> getBatch(String branchId, String batchId) async {
    try {
      final batch = await _remoteDataSource.getBatch(branchId, batchId);
      return Success<Batch>(batch);
    } on Object catch (error, stackTrace) {
      return Err<Batch>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<Batch>> createBatch(String branchId, BatchDraft draft) async {
    try {
      final batch = await _remoteDataSource.createBatch(branchId, draft);
      return Success<Batch>(batch);
    } on Object catch (error, stackTrace) {
      return Err<Batch>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<Batch>> updateBatch(
    String branchId,
    String batchId,
    BatchDraft draft,
  ) async {
    try {
      final batch = await _remoteDataSource.updateBatch(
        branchId,
        batchId,
        draft,
      );
      return Success<Batch>(batch);
    } on Object catch (error, stackTrace) {
      return Err<Batch>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> deleteBatch(String branchId, String batchId) async {
    try {
      await _remoteDataSource.deleteBatch(branchId, batchId);
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return Err<void>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> deactivateBatch(
    String branchId,
    String batchId,
  ) async {
    try {
      await _remoteDataSource.deactivateBatch(branchId, batchId);
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return Err<void>(ExceptionMapper.map(error, stackTrace));
    }
  }
}

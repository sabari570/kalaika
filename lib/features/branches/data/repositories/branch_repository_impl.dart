import 'package:feemanager/core/error/exception_mapper.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/branches/data/datasources/branch_remote_datasource.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/branches/domain/entities/branch_draft.dart';
import 'package:feemanager/features/branches/domain/repositories/branch_repository.dart';

/// Firestore implementation of [BranchRepository].
class BranchRepositoryImpl implements BranchRepository {
  /// Creates the repository.
  BranchRepositoryImpl({required this._remoteDataSource});

  final BranchRemoteDataSource _remoteDataSource;

  @override
  Stream<List<Branch>> watchBranches() {
    return _remoteDataSource.watchBranches();
  }

  @override
  Future<Result<Branch>> getBranch(String branchId) async {
    try {
      final branch = await _remoteDataSource.getBranch(branchId);
      return Success<Branch>(branch);
    } on Object catch (error, stackTrace) {
      return Err<Branch>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<Branch>> createBranch(BranchDraft draft) async {
    try {
      final branch = await _remoteDataSource.createBranch(draft);
      return Success<Branch>(branch);
    } on Object catch (error, stackTrace) {
      return Err<Branch>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<Branch>> updateBranch(
    String branchId,
    BranchDraft draft,
  ) async {
    try {
      final branch = await _remoteDataSource.updateBranch(branchId, draft);
      return Success<Branch>(branch);
    } on Object catch (error, stackTrace) {
      return Err<Branch>(ExceptionMapper.map(error, stackTrace));
    }
  }

  @override
  Future<Result<void>> deleteBranch(String branchId) async {
    try {
      await _remoteDataSource.deleteBranch(branchId);
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return Err<void>(ExceptionMapper.map(error, stackTrace));
    }
  }
}

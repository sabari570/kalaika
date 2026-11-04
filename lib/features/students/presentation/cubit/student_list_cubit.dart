import 'dart:async';

import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:feemanager/features/students/domain/usecases/set_student_active.dart';
import 'package:feemanager/features/students/domain/usecases/watch_students.dart';
import 'package:feemanager/features/students/presentation/cubit/student_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Maintains the student list for a batch.
class StudentListCubit extends Cubit<StudentListState> {
  /// Creates the cubit.
  StudentListCubit({
    required this._watchStudents,
    required this._setStudentActive,
  }) : super(const StudentListLoading());

  final WatchStudents _watchStudents;
  final SetStudentActive _setStudentActive;
  StreamSubscription<List<Student>>? _subscription;
  String? _branchId;
  String? _batchId;

  /// Starts listening for students in the batch.
  void started(String branchId, String batchId) {
    final sameBatch = _branchId == branchId && _batchId == batchId;
    _branchId = branchId;
    _batchId = batchId;
    unawaited(_subscription?.cancel());
    final current = state;
    if (sameBatch && current is StudentListLoaded) {
      emit(current.copyWith(refreshing: true));
    } else {
      emit(const StudentListLoading());
    }
    _subscription = _watchStudents(
      WatchStudentsParams(branchId: branchId, batchId: batchId),
    ).listen(
      (students) => emit(StudentListLoaded(students)),
      onError: (_) => emit(
        const StudentListFailure(AppStrings.unknownError),
      ),
    );
  }

  /// Cancels the student list listener.
  void stopListening() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  /// Toggles a student's active flag.
  Future<Result<void>> setActive({
    required String branchId,
    required String batchId,
    required String studentId,
    required bool isActive,
  }) {
    return _setStudentActive(
      SetStudentActiveParams(
        branchId: branchId,
        batchId: batchId,
        studentId: studentId,
        isActive: isActive,
      ),
    );
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}

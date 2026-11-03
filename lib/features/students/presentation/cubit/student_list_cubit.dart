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

  /// Starts listening for students in the batch.
  void started(String branchId, String batchId) {
    unawaited(_subscription?.cancel());
    emit(const StudentListLoading());
    _subscription = _watchStudents(
      WatchStudentsParams(branchId: branchId, batchId: batchId),
    ).listen(
      (students) => emit(StudentListLoaded(students)),
      onError: (_) => emit(
        const StudentListFailure(AppStrings.unknownError),
      ),
    );
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

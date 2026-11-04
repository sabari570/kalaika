import 'package:equatable/equatable.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';

/// Student list states for the batch students tab.
sealed class StudentListState extends Equatable {
  const StudentListState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Initial load.
final class StudentListLoading extends StudentListState {
  const StudentListLoading();
}

/// Students visible.
final class StudentListLoaded extends StudentListState {
  const StudentListLoaded(
    this.students, {
    this.refreshing = false,
  });

  final List<Student> students;

  /// True while re-attaching the stream.
  final bool refreshing;

  StudentListLoaded copyWith({
    List<Student>? students,
    bool? refreshing,
  }) {
    return StudentListLoaded(
      students ?? this.students,
      refreshing: refreshing ?? this.refreshing,
    );
  }

  @override
  List<Object?> get props => <Object?>[students, refreshing];
}

/// Stream failed.
final class StudentListFailure extends StudentListState {
  const StudentListFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

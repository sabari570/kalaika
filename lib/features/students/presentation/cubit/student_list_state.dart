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
  const StudentListLoaded(this.students);

  final List<Student> students;

  @override
  List<Object?> get props => <Object?>[students];
}

/// Stream failed.
final class StudentListFailure extends StudentListState {
  const StudentListFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

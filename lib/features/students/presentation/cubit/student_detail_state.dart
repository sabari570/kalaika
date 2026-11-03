import 'package:equatable/equatable.dart';
import 'package:feemanager/features/students/domain/entities/student.dart';
import 'package:feemanager/features/students/domain/entities/student_payment_summary.dart';

/// Student detail screen states.
sealed class StudentDetailState extends Equatable {
  const StudentDetailState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loading student and payments.
final class StudentDetailLoading extends StudentDetailState {
  const StudentDetailLoading();
}

/// Student profile and history loaded.
final class StudentDetailLoaded extends StudentDetailState {
  const StudentDetailLoaded({
    required this.student,
    required this.payments,
  });

  final Student student;
  final List<StudentPaymentSummary> payments;

  @override
  List<Object?> get props => <Object?>[student, payments];
}

/// Load failed.
final class StudentDetailFailure extends StudentDetailState {
  const StudentDetailFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

import 'package:equatable/equatable.dart';
import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/features/dashboard/domain/entities/dashboard_snapshot.dart';

/// Dashboard cubit states.
sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Initial load.
final class DashboardLoading extends DashboardState {
  /// Creates loading state.
  const DashboardLoading();
}

/// Failed to attach listeners.
final class DashboardFailure extends DashboardState {
  /// Creates failure state.
  const DashboardFailure(this.message);

  /// User-visible message.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Dashboard content for the selected month.
final class DashboardLoaded extends DashboardState {
  /// Creates loaded state.
  const DashboardLoaded({
    required this.user,
    required this.selectedMonth,
    required this.snapshot,
  });

  /// Signed-in user.
  final AppUser user;

  /// Selected calendar month.
  final DateTime selectedMonth;

  /// Aggregated metrics and branch cards.
  final DashboardSnapshot snapshot;

  @override
  List<Object?> get props => <Object?>[user, selectedMonth, snapshot];
}

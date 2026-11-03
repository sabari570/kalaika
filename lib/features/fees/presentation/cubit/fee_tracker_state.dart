import 'package:equatable/equatable.dart';
import 'package:feemanager/features/fees/domain/entities/fee_row.dart';

/// Fee tracker tab states.
sealed class FeeTrackerState extends Equatable {
  const FeeTrackerState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Initial load.
final class FeeTrackerLoading extends FeeTrackerState {
  const FeeTrackerLoading();
}

/// Rows ready to display.
final class FeeTrackerLoaded extends FeeTrackerState {
  const FeeTrackerLoaded({
    required this.selectedMonth,
    required this.rows,
    required this.filteredRows,
    required this.paidCount,
    required this.totalCount,
    required this.collected,
    required this.searchQuery,
    required this.filter,
    required this.monthKey,
  });

  final DateTime selectedMonth;
  final List<FeeRow> rows;
  final List<FeeRow> filteredRows;
  final int paidCount;
  final int totalCount;
  final int collected;
  final String searchQuery;
  final FeeListFilter filter;
  final String monthKey;

  FeeTrackerLoaded copyWith({
    List<FeeRow>? rows,
    List<FeeRow>? filteredRows,
    int? paidCount,
    int? totalCount,
    int? collected,
    String? searchQuery,
    FeeListFilter? filter,
    DateTime? selectedMonth,
    String? monthKey,
  }) {
    return FeeTrackerLoaded(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      rows: rows ?? this.rows,
      filteredRows: filteredRows ?? this.filteredRows,
      paidCount: paidCount ?? this.paidCount,
      totalCount: totalCount ?? this.totalCount,
      collected: collected ?? this.collected,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      monthKey: monthKey ?? this.monthKey,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    selectedMonth,
    rows,
    filteredRows,
    paidCount,
    totalCount,
    collected,
    searchQuery,
    filter,
    monthKey,
  ];
}

/// Stream error.
final class FeeTrackerFailure extends FeeTrackerState {
  const FeeTrackerFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

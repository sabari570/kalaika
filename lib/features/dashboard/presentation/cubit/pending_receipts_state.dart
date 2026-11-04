import 'package:equatable/equatable.dart';
import 'package:feemanager/features/dashboard/domain/entities/pending_receipt_item.dart';

/// Pending receipts list states.
sealed class PendingReceiptsState extends Equatable {
  const PendingReceiptsState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loading pending rows.
final class PendingReceiptsLoading extends PendingReceiptsState {
  /// Creates loading state.
  const PendingReceiptsLoading();
}

/// Failed to load.
final class PendingReceiptsFailure extends PendingReceiptsState {
  /// Creates failure state.
  const PendingReceiptsFailure(this.message);

  /// User-visible message.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Loaded pending rows.
final class PendingReceiptsLoaded extends PendingReceiptsState {
  /// Creates loaded state.
  const PendingReceiptsLoaded(this.items);

  /// Pending receipt rows.
  final List<PendingReceiptItem> items;

  @override
  List<Object?> get props => <Object?>[items];
}

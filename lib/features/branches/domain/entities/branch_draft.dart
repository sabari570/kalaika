import 'package:equatable/equatable.dart';

/// Input for creating or updating a branch.
class BranchDraft extends Equatable {
  /// Creates branch form values.
  const BranchDraft({
    required this.name,
    this.location = '',
    this.contactNumber = '',
  });

  /// Required branch name.
  final String name;

  /// Optional location.
  final String location;

  /// Optional contact number.
  final String contactNumber;

  @override
  List<Object?> get props => <Object?>[name, location, contactNumber];
}

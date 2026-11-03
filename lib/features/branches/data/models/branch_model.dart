import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/features/branches/domain/entities/branch.dart';
import 'package:feemanager/features/branches/domain/entities/branch_draft.dart';

/// Firestore DTO for `users/{uid}/branches/{branchId}`.
class BranchModel {
  /// Creates a branch model.
  const BranchModel({
    required this.id,
    required this.name,
    required this.location,
    required this.contactNumber,
    required this.batchCount,
    required this.studentCount,
    required this.isActive,
    required this.createdAt,
  });

  /// Builds a model from a Firestore snapshot.
  factory BranchModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return BranchModel(
      id: snapshot.id,
      name: data[FirestoreKeys.name] as String? ?? '',
      location: data[FirestoreKeys.location] as String? ?? '',
      contactNumber: data[FirestoreKeys.contactNumber] as String? ?? '',
      batchCount: (data[FirestoreKeys.batchCount] as num?)?.toInt() ?? 0,
      studentCount: (data[FirestoreKeys.studentCount] as num?)?.toInt() ?? 0,
      isActive: data[FirestoreKeys.isActive] as bool? ?? true,
      createdAt: _readTimestamp(data[FirestoreKeys.createdAt]),
    );
  }

  /// Document id.
  final String id;

  /// Branch name.
  final String name;

  /// Location text.
  final String location;

  /// Contact number.
  final String contactNumber;

  /// Batch counter.
  final int batchCount;

  /// Student counter.
  final int studentCount;

  /// Active flag.
  final bool isActive;

  /// Created timestamp.
  final DateTime createdAt;

  /// Converts to a domain entity.
  Branch toEntity() {
    return Branch(
      id: id,
      name: name,
      location: location,
      contactNumber: contactNumber,
      batchCount: batchCount,
      studentCount: studentCount,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  /// Map for creating a new branch document.
  static Map<String, Object?> createMap(BranchDraft draft) {
    return <String, Object?>{
      FirestoreKeys.name: draft.name.trim(),
      FirestoreKeys.location: draft.location.trim(),
      FirestoreKeys.contactNumber: draft.contactNumber.trim(),
      FirestoreKeys.batchCount: 0,
      FirestoreKeys.studentCount: 0,
      FirestoreKeys.isActive: true,
      FirestoreKeys.createdAt: FieldValue.serverTimestamp(),
    };
  }

  /// Map for updating branch fields.
  static Map<String, Object?> updateMap(BranchDraft draft) {
    return <String, Object?>{
      FirestoreKeys.name: draft.name.trim(),
      FirestoreKeys.location: draft.location.trim(),
      FirestoreKeys.contactNumber: draft.contactNumber.trim(),
    };
  }

  static DateTime _readTimestamp(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

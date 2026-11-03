import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/features/batches/domain/entities/batch.dart';
import 'package:feemanager/features/batches/domain/entities/batch_draft.dart';

/// Firestore DTO for a batch document.
class BatchModel {
  /// Creates a batch model.
  const BatchModel({
    required this.id,
    required this.ownerId,
    required this.branchId,
    required this.branchName,
    required this.name,
    required this.danceStyle,
    required this.mode,
    required this.days,
    required this.classTime,
    required this.defaultFee,
    required this.studentCount,
    required this.expectedMonthlyTotal,
    required this.isActive,
    required this.createdAt,
  });

  /// Builds from a Firestore snapshot.
  factory BatchModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return BatchModel(
      id: snapshot.id,
      ownerId: data[FirestoreKeys.ownerId] as String? ?? '',
      branchId: data[FirestoreKeys.branchId] as String? ?? '',
      branchName: data[FirestoreKeys.branchName] as String? ?? '',
      name: data[FirestoreKeys.name] as String? ?? '',
      danceStyle: data[FirestoreKeys.danceStyle] as String? ?? '',
      mode: data[FirestoreKeys.mode] as String? ?? '',
      days: (data[FirestoreKeys.days] as List<dynamic>? ?? <dynamic>[])
          .map((day) => day.toString())
          .toList(),
      classTime: data[FirestoreKeys.classTime] as String? ?? '',
      defaultFee: (data[FirestoreKeys.defaultFee] as num?)?.toInt() ?? 0,
      studentCount: (data[FirestoreKeys.studentCount] as num?)?.toInt() ?? 0,
      expectedMonthlyTotal:
          (data[FirestoreKeys.expectedMonthlyTotal] as num?)?.toInt() ?? 0,
      isActive: data[FirestoreKeys.isActive] as bool? ?? true,
      createdAt: _readTimestamp(data[FirestoreKeys.createdAt]),
    );
  }

  /// Document id.
  final String id;

  /// Owner uid.
  final String ownerId;

  /// Parent branch id.
  final String branchId;

  /// Denormalized branch name.
  final String branchName;

  /// Batch name.
  final String name;

  /// Dance style.
  final String danceStyle;

  /// Mode value.
  final String mode;

  /// Weekday keys.
  final List<String> days;

  /// Class time text.
  final String classTime;

  /// Default fee.
  final int defaultFee;

  /// Student counter.
  final int studentCount;

  /// Expected monthly total.
  final int expectedMonthlyTotal;

  /// Active flag.
  final bool isActive;

  /// Created timestamp.
  final DateTime createdAt;

  /// Converts to domain entity.
  Batch toEntity() {
    return Batch(
      id: id,
      ownerId: ownerId,
      branchId: branchId,
      branchName: branchName,
      name: name,
      danceStyle: danceStyle,
      mode: mode,
      days: days,
      classTime: classTime,
      defaultFee: defaultFee,
      studentCount: studentCount,
      expectedMonthlyTotal: expectedMonthlyTotal,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  /// Map for creating a batch.
  static Map<String, Object?> createMap({
    required String ownerId,
    required String branchId,
    required String branchName,
    required BatchDraft draft,
  }) {
    return <String, Object?>{
      FirestoreKeys.ownerId: ownerId,
      FirestoreKeys.branchId: branchId,
      FirestoreKeys.branchName: branchName,
      FirestoreKeys.name: draft.name.trim(),
      FirestoreKeys.danceStyle: draft.danceStyle.trim(),
      FirestoreKeys.mode: draft.mode,
      FirestoreKeys.days: draft.days,
      FirestoreKeys.classTime: draft.classTime.trim(),
      FirestoreKeys.defaultFee: draft.defaultFee,
      FirestoreKeys.studentCount: 0,
      FirestoreKeys.expectedMonthlyTotal: 0,
      FirestoreKeys.isActive: true,
      FirestoreKeys.createdAt: FieldValue.serverTimestamp(),
    };
  }

  /// Map for updating batch fields (excluding counters).
  static Map<String, Object?> updateMap(BatchDraft draft) {
    return <String, Object?>{
      FirestoreKeys.name: draft.name.trim(),
      FirestoreKeys.danceStyle: draft.danceStyle.trim(),
      FirestoreKeys.mode: draft.mode,
      FirestoreKeys.days: draft.days,
      FirestoreKeys.classTime: draft.classTime.trim(),
      FirestoreKeys.defaultFee: draft.defaultFee,
    };
  }

  static DateTime _readTimestamp(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

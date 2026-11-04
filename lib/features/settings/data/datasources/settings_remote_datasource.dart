import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/core/utils/firebase_user_scope.dart';
import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/features/fees/domain/entities/institute_settings.dart';
import 'package:feemanager/features/settings/data/models/user_settings_mapper.dart';
import 'package:feemanager/features/settings/domain/entities/user_settings_view.dart';

/// Firestore access for `users/{uid}` settings fields.
class SettingsRemoteDataSource {
  /// Creates the data source.
  SettingsRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Streams profile settings for [user].
  Stream<UserSettingsView> watchForUser(AppUser user) {
    return _firestore
        .collection(FirestoreKeys.users)
        .doc(user.uid)
        .snapshots()
        .map(
          (snapshot) => UserSettingsMapper.fromUserDocument(
            user,
            snapshot.data(),
          ),
        );
  }

  /// Updates institute details on the user profile.
  Future<void> updateInstitute(InstituteSettings institute) {
    final name = institute.name.trim();
    if (name.isEmpty) {
      throw const FormatException(AppStrings.settingsInstituteNameRequired);
    }
    final uid = FirebaseUserScope.requireUid();
    return _firestore.collection(FirestoreKeys.users).doc(uid).update(
      <String, Object?>{
        FirestoreKeys.institute: <String, Object?>{
          FirestoreKeys.name: name,
          FirestoreKeys.tagline: institute.tagline.trim(),
          FirestoreKeys.addressLines: institute.addressLines
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .toList(),
          FirestoreKeys.phone: institute.phone.trim(),
          FirestoreKeys.footerNote: institute.footerNote.trim(),
          FirestoreKeys.signatory: institute.signatory.trim(),
        },
      },
    );
  }

  /// Updates the WhatsApp message template.
  Future<void> updateMessageTemplate(String template) {
    final uid = FirebaseUserScope.requireUid();
    return _firestore.collection(FirestoreKeys.users).doc(uid).update(
      <String, Object?>{
        FirestoreKeys.messageTemplate: template,
      },
    );
  }
}

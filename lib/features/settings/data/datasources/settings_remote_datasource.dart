import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/features/auth/domain/entities/app_user.dart';
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
}

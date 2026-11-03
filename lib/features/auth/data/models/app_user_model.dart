import 'package:feemanager/features/auth/domain/entities/app_user.dart';

/// Maps a Firebase user snapshot to [AppUser].
class AppUserModel {
  /// Creates a model from Firebase user fields.
  const AppUserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  /// Firebase uid.
  final String uid;

  /// Account email.
  final String email;

  /// Profile display name.
  final String displayName;

  /// Profile photo URL.
  final String? photoUrl;

  /// Converts to a domain entity.
  AppUser toEntity() {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}

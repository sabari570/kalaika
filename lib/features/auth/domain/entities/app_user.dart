import 'package:equatable/equatable.dart';

/// Signed-in teacher account from Firebase Authentication.
class AppUser extends Equatable {
  /// Creates an authenticated user.
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  /// Firebase Authentication user id.
  final String uid;

  /// Google account email address.
  final String email;

  /// Display name from the Google profile.
  final String displayName;

  /// Optional profile photo URL.
  final String? photoUrl;

  /// First token of [displayName] for greetings.
  String get firstName {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      return displayName;
    }
    return trimmed.split(RegExp(r'\s+')).first;
  }

  @override
  List<Object?> get props => <Object?>[uid, email, displayName, photoUrl];
}

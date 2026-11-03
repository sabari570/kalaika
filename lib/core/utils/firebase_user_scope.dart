import 'package:firebase_auth/firebase_auth.dart';

/// Resolves the signed-in Firebase user id for Firestore paths.
abstract final class FirebaseUserScope {
  /// Returns the current uid or throws if absent.
  static String requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('No authenticated user');
    }
    return uid;
  }
}

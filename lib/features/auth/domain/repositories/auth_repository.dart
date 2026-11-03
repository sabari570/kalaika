import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/features/auth/domain/entities/app_user.dart';

/// Authentication and user profile persistence.
abstract class AuthRepository {
  /// Most recently observed user, if any.
  AppUser? get currentUser;

  /// Emits whenever the signed-in user changes.
  Stream<AppUser?> watchAuthUser();

  /// Initializes Firebase and Google Sign-In clients.
  Future<Result<void>> initialize();

  /// Signs in with Google and ensures the Firestore user document exists.
  Future<Result<AppUser>> signInWithGoogle();

  /// Signs out of Firebase and Google.
  Future<Result<void>> signOut();
}

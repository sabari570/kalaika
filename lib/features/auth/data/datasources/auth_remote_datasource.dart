import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';
import 'package:feemanager/features/auth/data/datasources/auth_exceptions.dart';
import 'package:feemanager/features/auth/data/models/app_user_model.dart';
import 'package:feemanager/features/auth/data/models/user_profile_model.dart';
import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Remote authentication via Firebase Auth, Google Sign-In, and Firestore.
class AuthRemoteDataSource {
  /// Creates the data source with injectable clients for testing.
  AuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  var _initialized = false;

  /// Initializes Google Sign-In (Firebase Core is initialized at app startup).
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    // NOTE: Firebase.initializeApp runs in main.dart before DI, because the
    // auth router listens to Firebase Auth as soon as the app widget builds.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await _googleSignIn.initialize();
    _initialized = true;
  }

  /// Auth state changes mapped to domain users.
  Stream<AppUser?> watchAuthUser() {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  /// Interactive Google sign-in linked to Firebase Auth.
  Future<AppUser> signInWithGoogle() async {
    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const SignInFailedException(AppStrings.signInFailed);
    }
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _firebaseAuth.signInWithCredential(
      credential,
    );
    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw const SignInFailedException(AppStrings.signInFailed);
    }
    await _ensureUserDocument(firebaseUser);
    final mapped = _mapFirebaseUser(firebaseUser);
    if (mapped == null) {
      throw const SignInFailedException(AppStrings.signInFailed);
    }
    return mapped;
  }

  /// Signs out of Firebase Auth and Google.
  Future<void> signOut() async {
    await Future.wait(<Future<void>>[
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  AppUser? _mapFirebaseUser(User? user) {
    if (user == null) {
      return null;
    }
    return AppUserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? user.email ?? '',
      photoUrl: user.photoURL,
    ).toEntity();
  }

  Future<void> _ensureUserDocument(User user) async {
    final docRef = _firestore
        .collection(FirestoreKeys.users)
        .doc(user.uid);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      return;
    }
    final data = UserProfileModel.newUserDocument(
      displayName: user.displayName ?? user.email ?? '',
      email: user.email ?? '',
    );
    data[FirestoreKeys.createdAt] = FieldValue.serverTimestamp();
    await docRef.set(data);
    developer.log(
      'Created user profile document',
      name: 'AuthRemoteDataSource',
    );
  }
}

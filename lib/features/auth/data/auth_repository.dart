// ---------------------------------------------------------------
// auth_repository.dart
//
// PURPOSE: Data layer for authentication.  Wraps Firebase Auth
// phone-OTP methods and Firestore user-document CRUD.  This is
// the single source of truth for auth-related backend calls.
// ---------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/constants.dart';
import '../../../models/app_user.dart';

/// Repository that handles phone-based authentication and user
/// profile storage in Firestore.
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Phone OTP ──────────────────────────────────────────────

  /// Initiates phone number verification.
  ///
  /// Firebase will either auto-retrieve the SMS code (Android) or
  /// call [codeSent] with a verification ID that the user must
  /// manually enter.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      forceResendingToken: forceResendingToken,
      timeout: const Duration(seconds: AppConstants.otpTimeoutSeconds),
    );
  }

  /// Signs in using the SMS code the user entered.
  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  // ── Firestore user document ────────────────────────────────

  /// Fetches the [AppUser] document from Firestore for [uid].
  /// Returns `null` if the document does not exist (first-time user).
  Future<AppUser?> getUser(String uid) async {
    final doc = await _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .get();

    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  /// Creates a new user document in Firestore after role selection.
  Future<void> createUser(AppUser user) async {
    await _firestore
        .collection(FirestorePaths.users)
        .doc(user.uid)
        .set(user.toFirestore());
  }

  // ── Session helpers ────────────────────────────────────────

  /// Returns the currently signed-in Firebase user, or `null`.
  User? get currentUser => _auth.currentUser;

  /// Signs the user out of Firebase Auth.
  Future<void> signOut() async => _auth.signOut();

  /// Stream of auth state changes (sign-in / sign-out).
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}

// ---------------------------------------------------------------
// auth_providers.dart
//
// PURPOSE: Riverpod providers that expose auth state and the
// AuthRepository to the widget tree.  Screens read these
// providers to react to auth changes without directly
// depending on Firebase.
// ---------------------------------------------------------------

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/app_user.dart';
import '../data/auth_repository.dart';

/// Provides a singleton [AuthRepository] instance.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Streams Firebase Auth state changes (sign-in / sign-out).
/// Widgets can watch this to decide whether to show the auth
/// flow or the main app.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Fetches the Firestore [AppUser] document for the current user.
/// Returns `null` if the user hasn't chosen a role yet.
final appUserProvider = FutureProvider<AppUser?>((ref) async {
  final authState = ref.watch(authStateProvider).valueOrNull;
  if (authState == null) return null;

  return ref.watch(authRepositoryProvider).getUser(authState.uid);
});

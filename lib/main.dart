// ---------------------------------------------------------------
// main.dart
//
// PURPOSE: Application entry point.  Initialises Firebase and
// wraps the widget tree in a Riverpod [ProviderScope] so all
// providers are available throughout the app.
// ---------------------------------------------------------------

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/firebase_service.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter bindings are ready before calling async code.
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialise Firebase ──────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Set up Firebase Cloud Messaging ──────────────────────────
  await FirebaseService().initNotifications();

  // ── Launch the app with Riverpod ─────────────────────────────
  runApp(
    const ProviderScope(
      child: LocalServeApp(),
    ),
  );
}

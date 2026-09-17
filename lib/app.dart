// ---------------------------------------------------------------
// app.dart
//
// PURPOSE: Root MaterialApp widget.  Uses MaterialApp.router with
// GoRouter for declarative, URI-based navigation.  Defines the
// app-wide theme and color scheme.
// ---------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'routing/app_router.dart';

/// The root widget of the LocalServe app.
class LocalServeApp extends StatelessWidget {
  const LocalServeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LocalServe',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF), // primary purple
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),

      // ── Router ─────────────────────────────────────────────
      routerConfig: appRouter,
    );
  }
}

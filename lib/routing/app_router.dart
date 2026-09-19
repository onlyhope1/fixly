// ---------------------------------------------------------------
// app_router.dart
//
// PURPOSE: Centralised GoRouter configuration.  Defines every
// route in the app and maps URL paths to screen widgets.
// The splash screen is the initial route; auth screens are
// top-level routes; the customer bottom-nav shell wraps the
// four main tabs.  The Home tab has nested routes for
// category detail and provider detail screens.
// ---------------------------------------------------------------

import 'package:go_router/go_router.dart';

import '../features/auth/screens/otp_verification_screen.dart';
import '../features/auth/screens/phone_entry_screen.dart';
import '../features/auth/screens/role_selection_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/booking/screens/bookings_screen.dart';
import '../features/home/screens/category_detail_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/provider_detail_screen.dart';
import '../features/messages/screens/messages_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'customer_shell.dart';

/// The app-wide GoRouter instance.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Auth routes ────────────────────────────────────────────
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/phone',
      builder: (context, state) => const PhoneEntryScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        // Extract verification data passed via `extra`.
        final extras = state.extra! as Map<String, dynamic>;
        return OtpVerificationScreen(
          verificationId: extras['verificationId'] as String,
          phoneNumber: extras['phoneNumber'] as String,
        );
      },
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),

    // ── Customer bottom-navigation shell ───────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CustomerShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0 — Home (with nested category/provider routes)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                // Category detail — /home/category/:categoryId
                GoRoute(
                  path: 'category/:categoryId',
                  builder: (context, state) {
                    final categoryId =
                        state.pathParameters['categoryId']!;
                    final categoryName =
                        state.extra as String? ?? 'Category';
                    return CategoryDetailScreen(
                      categoryId: categoryId,
                      categoryName: categoryName,
                    );
                  },
                ),
                // Provider detail — /home/provider/:providerId
                GoRoute(
                  path: 'provider/:providerId',
                  builder: (context, state) {
                    final providerId =
                        state.pathParameters['providerId']!;
                    return ProviderDetailScreen(
                      providerId: providerId,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 1 — Bookings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bookings',
              builder: (context, state) => const BookingsScreen(),
            ),
          ],
        ),
        // Tab 2 — Messages
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/messages',
              builder: (context, state) => const MessagesScreen(),
            ),
          ],
        ),
        // Tab 3 — Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

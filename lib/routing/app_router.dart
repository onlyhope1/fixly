// ---------------------------------------------------------------
// app_router.dart
//
// PURPOSE: Centralised GoRouter configuration.  Defines auth
// routes, customer bottom-nav shell (with nested category,
// provider detail, and booking form routes), and provider
// bottom-nav shell (with dashboard and jobs routes).
// ---------------------------------------------------------------

import 'package:go_router/go_router.dart';

import '../features/auth/screens/otp_verification_screen.dart';
import '../features/auth/screens/phone_entry_screen.dart';
import '../features/auth/screens/role_selection_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/booking/screens/booking_form_screen.dart';
import '../features/booking/screens/bookings_screen.dart';
import '../features/booking/screens/provider_dashboard_screen.dart';
import '../features/booking/screens/provider_jobs_screen.dart';
import '../features/home/screens/category_detail_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/provider_detail_screen.dart';
import '../features/messages/screens/messages_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'customer_shell.dart';
import 'provider_shell.dart';

/// The app-wide GoRouter instance.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // \u2500\u2500 Auth routes \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
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

    // \u2500\u2500 Customer bottom-navigation shell \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CustomerShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0 \u2014 Home (with nested category, provider, booking routes)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
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
                GoRoute(
                  path: 'provider/:providerId',
                  builder: (context, state) {
                    final providerId =
                        state.pathParameters['providerId']!;
                    return ProviderDetailScreen(
                      providerId: providerId,
                    );
                  },
                  routes: [
                    // Booking form \u2014 /home/provider/:providerId/book
                    GoRoute(
                      path: 'book',
                      builder: (context, state) {
                        final providerId =
                            state.pathParameters['providerId']!;
                        final extras =
                            state.extra! as Map<String, dynamic>;
                        return BookingFormScreen(
                          providerId: providerId,
                          providerName:
                              extras['providerName'] as String,
                          hourlyRate:
                              extras['hourlyRate'] as double,
                          serviceId:
                              extras['serviceId'] as String,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Tab 1 \u2014 Bookings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bookings',
              builder: (context, state) => const BookingsScreen(),
            ),
          ],
        ),
        // Tab 2 \u2014 Messages
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/messages',
              builder: (context, state) => const MessagesScreen(),
            ),
          ],
        ),
        // Tab 3 \u2014 Profile
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

    // \u2500\u2500 Provider bottom-navigation shell \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ProviderShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0 \u2014 Dashboard (incoming requests)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/provider-dashboard',
              builder: (context, state) =>
                  const ProviderDashboardScreen(),
            ),
          ],
        ),
        // Tab 1 \u2014 My Jobs
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/provider-jobs',
              builder: (context, state) =>
                  const ProviderJobsScreen(),
            ),
          ],
        ),
        // Tab 2 \u2014 Messages
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/provider-messages',
              builder: (context, state) =>
                  const MessagesScreen(),
            ),
          ],
        ),
        // Tab 3 \u2014 Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/provider-profile',
              builder: (context, state) =>
                  const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

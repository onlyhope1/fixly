// ---------------------------------------------------------------
// splash_screen.dart
//
// PURPOSE: The first screen the user sees.  Displays the app logo
// and name for 2 seconds, then redirects based on auth state and
// user role (customers go to /home, providers go to /provider-dashboard).
// ---------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';

/// Splash screen shown at app launch.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final authState = ref.read(authStateProvider);

    authState.when(
      data: (user) async {
        if (user == null) {
          context.go('/phone');
        } else {
          final appUser = await ref.read(appUserProvider.future);
          if (!mounted) return;

          if (appUser == null) {
            context.go('/role-selection');
          } else if (appUser.isCustomer) {
            // Customer → customer home.
            context.go('/home');
          } else {
            // Provider → provider dashboard.
            context.go('/provider-dashboard');
          }
        }
      },
      loading: () {
        Future.delayed(const Duration(seconds: 1), _navigate);
      },
      error: (e, _) => context.go('/phone'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.home_repair_service_rounded,
              size: 80,
              color: theme.colorScheme.onPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              'LocalServe',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Local services at your doorstep',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

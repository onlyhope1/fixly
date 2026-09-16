// ---------------------------------------------------------------
// role_selection_screen.dart
//
// PURPOSE: Shown after first-time signup so the user can choose
// their role — "customer" (looking for services) or "provider"
// (offering services).  The selection is saved in the Firestore
// `users` collection, then the user is routed to the main app.
// ---------------------------------------------------------------

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/constants.dart';
import '../../../models/app_user.dart';
import '../providers/auth_providers.dart';

/// Screen for selecting the user's role after initial sign-up.
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  /// Saves the chosen role to Firestore and navigates to home.
  Future<void> _saveRole() async {
    if (_selectedRole == null) return;

    setState(() => _isLoading = true);

    final firebaseUser = FirebaseAuth.instance.currentUser!;
    final authRepo = ref.read(authRepositoryProvider);

    final newUser = AppUser(
      uid: firebaseUser.uid,
      phoneNumber: firebaseUser.phoneNumber ?? '',
      role: _selectedRole!,
      createdAt: DateTime.now(),
    );

    await authRepo.createUser(newUser);

    if (!mounted) return;

    // Invalidate the cached user provider so it refetches.
    ref.invalidate(appUserProvider);

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // ── Header ──────────────────────────────────────
              Text(
                'How will you use LocalServe?',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your role to get started',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),

              // ── Customer card ───────────────────────────────
              _RoleCard(
                icon: Icons.person_rounded,
                title: 'Customer',
                subtitle: 'I\'m looking for local services',
                isSelected: _selectedRole == UserRoles.customer,
                onTap: () => setState(() => _selectedRole = UserRoles.customer),
              ),
              const SizedBox(height: 16),

              // ── Provider card ───────────────────────────────
              _RoleCard(
                icon: Icons.handyman_rounded,
                title: 'Service Provider',
                subtitle: 'I want to offer my services',
                isSelected: _selectedRole == UserRoles.provider,
                onTap: () => setState(() => _selectedRole = UserRoles.provider),
              ),
              const SizedBox(height: 48),

              // ── Continue button ─────────────────────────────
              FilledButton(
                onPressed:
                    _selectedRole == null || _isLoading ? null : _saveRole,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue'),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private helper widget ──────────────────────────────────────

/// A selectable card representing a user role.
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : Colors.grey[300]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

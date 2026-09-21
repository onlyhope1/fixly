// ---------------------------------------------------------------
// role_selection_screen.dart
//
// PURPOSE: Shown after first-time signup so the user can choose
// their role.  Customers route to /home; providers also get a
// basic profile created in the `providers` collection (using
// auth UID as doc ID) and route to /provider-dashboard.
// ---------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Saves the chosen role to Firestore and navigates accordingly.
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

    // If provider, also create a basic profile in the providers
    // collection using auth UID as doc ID so bookings can link.
    if (_selectedRole == UserRoles.provider) {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.providers)
          .doc(firebaseUser.uid)
          .set({
        'name': firebaseUser.phoneNumber ?? 'New Provider',
        'categoryId': '',
        'rating': 0.0,
        'totalReviews': 0,
        'hourlyRate': 300,
        'location': const GeoPoint(28.6139, 77.2090),
        'city': 'New Delhi',
        'available': true,
        'photoUrl': '',
        'about': 'New service provider on LocalServe.',
      });
    }

    if (!mounted) return;

    ref.invalidate(appUserProvider);

    // Route based on role.
    if (_selectedRole == UserRoles.customer) {
      context.go('/home');
    } else {
      context.go('/provider-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'How will you use LocalServe?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your role to get started',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 48),
                _RoleCard(
                  icon: Icons.person_rounded,
                  title: 'Customer',
                  subtitle: 'I\'m looking for local services',
                  isSelected: _selectedRole == UserRoles.customer,
                  onTap: () =>
                      setState(() => _selectedRole = UserRoles.customer),
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  icon: Icons.handyman_rounded,
                  title: 'Service Provider',
                  subtitle: 'I want to offer my services',
                  isSelected: _selectedRole == UserRoles.provider,
                  onTap: () =>
                      setState(() => _selectedRole = UserRoles.provider),
                ),
                const SizedBox(height: 48),
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
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: theme.colorScheme.onPrimary),
                        )
                      : const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant;

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
              : theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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

// ---------------------------------------------------------------
// customer_shell.dart
//
// PURPOSE: The bottom navigation "shell" scaffold for customers.
// Wraps four tabs (Home, Bookings, Messages, Profile) and uses
// GoRouter's StatefulNavigationShell to preserve tab state across
// navigation.
// ---------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A scaffold with a [NavigationBar] that wraps the four customer
/// tabs.  Uses [StatefulNavigationShell] so each tab maintains its
/// own navigation stack.
class CustomerShell extends StatelessWidget {
  /// The navigation shell provided by GoRouter's StatefulShellRoute.
  final StatefulNavigationShell navigationShell;

  const CustomerShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The current tab's widget tree.
      body: navigationShell,

      // ── Bottom navigation bar ─────────────────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // goBranch switches to the selected tab branch.
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

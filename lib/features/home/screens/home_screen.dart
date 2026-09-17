// ---------------------------------------------------------------
// home_screen.dart
//
// PURPOSE: Placeholder home tab for the customer.  Will later
// display service categories, featured providers, etc.
// ---------------------------------------------------------------

import 'package:flutter/material.dart';

/// Placeholder screen for the Home tab.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_repair_service_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Welcome to LocalServe!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Service categories will appear here.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

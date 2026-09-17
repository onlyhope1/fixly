// ---------------------------------------------------------------
// bookings_screen.dart
//
// PURPOSE: Placeholder bookings tab.  Will later show the list
// of upcoming and past service bookings for the customer.
// ---------------------------------------------------------------

import 'package:flutter/material.dart';

/// Placeholder screen for the Bookings tab.
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No bookings yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your upcoming bookings will appear here.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

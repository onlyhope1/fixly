// ---------------------------------------------------------------
// empty_view.dart
//
// PURPOSE: A reusable empty-state widget that shows an icon,
// title, and optional subtitle.  Use this when a Firestore query
// returns zero results.
// ---------------------------------------------------------------

import 'package:flutter/material.dart';

/// Displays an empty state with an icon, title, and subtitle.
class EmptyView extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The main title text.
  final String title;

  /// An optional explanatory subtitle.
  final String subtitle;

  const EmptyView({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    this.subtitle = '',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

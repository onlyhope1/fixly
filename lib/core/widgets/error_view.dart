// ---------------------------------------------------------------
// error_view.dart
//
// PURPOSE: A reusable error-state widget that shows an icon,
// error message, and an optional "Retry" button.  Use this as
// the body of any screen that fails to load data.
// ---------------------------------------------------------------

import 'package:flutter/material.dart';

/// Displays an error state with an icon, message, and retry button.
class ErrorView extends StatelessWidget {
  /// The error message to display.
  final String message;

  /// Called when the user taps "Retry".  If null, no button is shown.
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    this.message = 'Something went wrong',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

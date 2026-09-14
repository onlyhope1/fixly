// ---------------------------------------------------------------
// loading_indicator.dart
//
// PURPOSE: A reusable, centered loading spinner widget.
// Avoids duplicating CircularProgressIndicator boilerplate across
// multiple screens.
// ---------------------------------------------------------------

import 'package:flutter/material.dart';

/// A centered [CircularProgressIndicator] wrapped in a [Scaffold]-safe
/// layout.  Use this as the body of any screen that is loading data.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}

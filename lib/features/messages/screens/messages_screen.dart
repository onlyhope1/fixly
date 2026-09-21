// ---------------------------------------------------------------
// messages_screen.dart
//
// PURPOSE: Placeholder messages tab.  Will later display chat
// conversations between customers and service providers.
// ---------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/widgets/empty_view.dart';

/// Placeholder screen for the Messages tab.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const EmptyView(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'No messages yet',
        subtitle: 'Chat with service providers here.',
      ),
    );
  }
}

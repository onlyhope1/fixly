// ---------------------------------------------------------------
// firebase_service.dart
//
// PURPOSE: Helper class that wraps Firebase Messaging setup.
// Requests notification permissions and retrieves the FCM token
// so the app can receive push notifications.
// ---------------------------------------------------------------

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handles Firebase Cloud Messaging (FCM) initialization.
class FirebaseService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Requests notification permissions from the user and prints
  /// the FCM device token (useful for testing push notifications).
  Future<void> initNotifications() async {
    // Request permission (iOS requires this; Android auto-grants).
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'FCM permission status: ${settings.authorizationStatus}',
    );

    // Retrieve the device token for sending targeted messages.
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
  }
}

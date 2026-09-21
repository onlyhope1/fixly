import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendNotification({
    required String targetUserId,
    required String title,
    required String body,
  }) async {
    try {
      final doc = await _firestore
          .collection(FirestorePaths.users)
          .doc(targetUserId)
          .get();
      
      if (!doc.exists) return;
      
      final data = doc.data();
      if (data == null) return;
      
      final token = data['fcmToken'] as String?;
      if (token == null || token.isEmpty) return;

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=YOUR_SERVER_KEY',
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
          },
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to send notification: ${response.statusCode} - ${response.body}');
      } else {
        debugPrint('Notification sent successfully to $targetUserId');
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }
}

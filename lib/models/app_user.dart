// ---------------------------------------------------------------
// app_user.dart
//
// PURPOSE: Data model representing a user in the Firestore `users`
// collection.  Each user has a UID (from Firebase Auth), a phone
// number, a role ("customer" or "provider"), and a creation
// timestamp.
// ---------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user stored in the Firestore `users` collection.
class AppUser {
  final String uid;
  final String phoneNumber;
  final String role; // 'customer' or 'provider'
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.phoneNumber,
    required this.role,
    required this.createdAt,
  });

  // ── Firestore serialization ────────────────────────────────

  /// Creates an [AppUser] from a Firestore document snapshot.
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      phoneNumber: data['phoneNumber'] as String,
      role: data['role'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Converts this user to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Returns `true` if the user is a customer.
  bool get isCustomer => role == 'customer';

  /// Returns `true` if the user is a service provider.
  bool get isProvider => role == 'provider';
}

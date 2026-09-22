// ---------------------------------------------------------------
// booking.dart
//
// PURPOSE: Data model for a booking stored in the Firestore
// `bookings` collection.  Links a customer to a provider for a
// specific service, date/time, and location.  Includes an
// overlap-detection helper for double-booking prevention.
// ---------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a service booking from the Firestore `bookings` collection.
class Booking {
  final String id;
  final String customerId;
  final String providerId;
  final String serviceId;
  final String serviceName;
  final String providerName;
  final String customerPhone;
  final DateTime scheduledTime;
  final int durationHours;
  final String status;
  final String address;
  final double price;
  final String notes;
  final DateTime createdAt;
  final bool isRated;

  const Booking({
    required this.id,
    required this.customerId,
    required this.providerId,
    required this.serviceId,
    required this.serviceName,
    required this.providerName,
    required this.customerPhone,
    required this.scheduledTime,
    required this.durationHours,
    required this.status,
    required this.address,
    required this.price,
    required this.notes,
    required this.createdAt,
    this.isRated = false,
  });

  // ── Firestore serialization ────────────────────────────────

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      customerId: data['customerId'] as String,
      providerId: data['providerId'] as String,
      serviceId: data['serviceId'] as String? ?? '',
      serviceName: data['serviceName'] as String? ?? '',
      providerName: data['providerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      durationHours: data['durationHours'] as int? ?? 1,
      status: data['status'] as String,
      address: data['address'] as String? ?? '',
      price: (data['price'] as num).toDouble(),
      notes: data['notes'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRated: data['isRated'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'providerId': providerId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'providerName': providerName,
      'customerPhone': customerPhone,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'durationHours': durationHours,
      'status': status,
      'address': address,
      'price': price,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRated': isRated,
    };
  }

  // ── Time helpers ──────────────────────────────────────────

  /// The end time calculated from start + duration.
  DateTime get endTime =>
      scheduledTime.add(Duration(hours: durationHours));

  /// Returns `true` if this booking's time window overlaps with [other].
  /// Used for double-booking detection.
  bool overlaps(Booking other) {
    return scheduledTime.isBefore(other.endTime) &&
        endTime.isAfter(other.scheduledTime);
  }
}

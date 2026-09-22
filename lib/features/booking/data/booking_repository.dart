// ---------------------------------------------------------------
// booking_repository.dart
//
// PURPOSE: Data layer for bookings.  Handles Firestore CRUD for
// the `bookings` collection and provides a double-booking
// detection method that checks for overlapping accepted slots.
//
// NOTE: Some queries require composite Firestore indexes.
// On first run, Firestore will log an error with a direct link
// to create the needed index — click it to auto-create.
// ---------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/utils/constants.dart';
import '../../../models/booking.dart';
import '../../../models/review.dart';

import '../../../core/services/notification_service.dart';

/// Repository that handles Firestore CRUD for bookings.
class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a new booking document in Firestore.
  Future<String> createBooking(Booking booking) async {
    final docRef = _firestore.collection(FirestorePaths.bookings).doc();
    await docRef.set(booking.toFirestore());
    return docRef.id;
  }

  /// Updates the status of an existing booking.
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore
        .collection(FirestorePaths.bookings)
        .doc(bookingId)
        .update({'status': status});

    try {
      final doc = await _firestore.collection(FirestorePaths.bookings).doc(bookingId).get();
      if (!doc.exists) return;
      final booking = Booking.fromFirestore(doc);
      
      if (status == BookingStatus.pending) {
        // Customer just paid successfully
        await NotificationService.instance.sendNotification(
          targetUserId: booking.providerId,
          title: 'New Booking Request',
          body: 'You have a new request from ${booking.customerPhone}',
        );
      } else if (status == BookingStatus.accepted) {
        await NotificationService.instance.sendNotification(
          targetUserId: booking.customerId,
          title: 'Booking Accepted',
          body: '${booking.providerName} has accepted your booking.',
        );
      } else if (status == BookingStatus.rejected) {
        await NotificationService.instance.sendNotification(
          targetUserId: booking.customerId,
          title: 'Booking Rejected',
          body: '${booking.providerName} could not accept your booking.',
        );
      }
    } catch (e) {
      // Ignore notification failures so it doesn't break the app flow
      debugPrint('Failed to send notification: $e');
    }
  }

  // ── Customer queries ──────────────────────────────────────

  /// Streams all bookings for a customer, newest first.
  Stream<List<Booking>> getCustomerBookings(String customerId) {
    return _firestore
        .collection(FirestorePaths.bookings)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => Booking.fromFirestore(d)).toList());
  }

  // ── Provider queries ──────────────────────────────────────

  /// Streams pending booking requests for a provider.
  Stream<List<Booking>> getProviderPendingBookings(String providerId) {
    return _firestore
        .collection(FirestorePaths.bookings)
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: BookingStatus.pending)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => Booking.fromFirestore(d)).toList());
  }

  /// Streams accepted (upcoming) bookings for a provider.
  Stream<List<Booking>> getProviderAcceptedBookings(String providerId) {
    return _firestore
        .collection(FirestorePaths.bookings)
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: BookingStatus.accepted)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => Booking.fromFirestore(d)).toList());
  }

  // ── Double-booking detection ──────────────────────────────

  /// Checks if accepting a booking would create a schedule conflict.
  ///
  /// Returns a list of accepted bookings on the same day that overlap
  /// with the proposed time slot.  An empty list means no conflict.
  Future<List<Booking>> checkDoubleBooking({
    required String providerId,
    required DateTime scheduledTime,
    required int durationHours,
  }) async {
    // Query accepted bookings for this provider on the same day.
    final dayStart = DateTime(
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
    );
    final dayEnd = dayStart.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection(FirestorePaths.bookings)
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: BookingStatus.accepted)
        .where('scheduledTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('scheduledTime',
            isLessThan: Timestamp.fromDate(dayEnd))
        .get();

    // Build a temporary booking to check overlap against.
    final proposed = Booking(
      id: '',
      customerId: '',
      providerId: providerId,
      serviceId: '',
      serviceName: '',
      providerName: '',
      customerPhone: '',
      scheduledTime: scheduledTime,
      durationHours: durationHours,
      status: BookingStatus.pending,
      address: '',
      price: 0,
      notes: '',
      createdAt: DateTime.now(),
    );

    // Filter to only those that actually overlap.
    return snapshot.docs
        .map((d) => Booking.fromFirestore(d))
        .where((existing) => proposed.overlaps(existing))
        .toList();
  }

  /// Submits a review and updates provider rating/totalReviews and booking isRated status
  Future<void> submitReview({required String providerId, required Review review}) async {
    final providerRef = _firestore.collection('providers').doc(providerId);
    final reviewRef = providerRef.collection('reviews').doc(review.id.isEmpty ? null : review.id);
    final bookingRef = _firestore.collection(FirestorePaths.bookings).doc(review.bookingId);

    await _firestore.runTransaction((transaction) async {
      final providerDoc = await transaction.get(providerRef);
      if (!providerDoc.exists) {
        throw Exception('Provider does not exist!');
      }

      final data = providerDoc.data()!;
      final int totalReviews = (data['totalReviews'] as int?) ?? 0;
      final double currentRating = (data['rating'] as num?)?.toDouble() ?? 0.0;

      final newTotalReviews = totalReviews + 1;
      final newRating = ((currentRating * totalReviews) + review.rating) / newTotalReviews;

      transaction.set(reviewRef, review.toFirestore());
      transaction.update(providerRef, {
        'totalReviews': newTotalReviews,
        'rating': newRating,
      });
      transaction.update(bookingRef, {
        'isRated': true,
      });
    });
  }
}

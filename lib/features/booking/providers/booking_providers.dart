// ---------------------------------------------------------------
// booking_providers.dart
//
// PURPOSE: Riverpod providers that expose booking state to the
// widget tree.  Customer screens watch their bookings; provider
// screens watch incoming requests and accepted jobs.
// ---------------------------------------------------------------

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/booking.dart';
import '../data/booking_repository.dart';

/// Provides a singleton [BookingRepository] instance.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});

/// Streams all bookings for the currently logged-in customer.
final customerBookingsProvider = StreamProvider<List<Booking>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);
  return ref.watch(bookingRepositoryProvider).getCustomerBookings(uid);
});

/// Streams pending booking requests for the logged-in provider.
/// The provider's auth UID is used as their provider doc ID.
final providerPendingBookingsProvider =
    StreamProvider<List<Booking>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);
  return ref
      .watch(bookingRepositoryProvider)
      .getProviderPendingBookings(uid);
});

/// Streams accepted/upcoming bookings for the logged-in provider.
final providerAcceptedBookingsProvider =
    StreamProvider<List<Booking>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);
  return ref
      .watch(bookingRepositoryProvider)
      .getProviderAcceptedBookings(uid);
});

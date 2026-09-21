// ---------------------------------------------------------------
// constants.dart
//
// PURPOSE: Central place for app-wide constants such as Firestore
// collection names, default values, and configuration strings.
// ---------------------------------------------------------------

/// Firestore collection paths.
class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';
  static const String services = 'services';
  static const String providers = 'providers';
  static const String bookings = 'bookings';
}

/// User role identifiers stored in the Firestore `role` field.
class UserRoles {
  UserRoles._();

  static const String customer = 'customer';
  static const String provider = 'provider';
}

/// Booking status values stored in the `status` field.
class BookingStatus {
  BookingStatus._();

  static const String pending = 'pending';
  static const String pendingPayment = 'pending_payment';
  static const String accepted = 'accepted';
  static const String rejected = 'rejected';
  static const String completed = 'completed';
}

/// App-wide UI constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'LocalServe';
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 60;
  static const int defaultDurationHours = 1;
}

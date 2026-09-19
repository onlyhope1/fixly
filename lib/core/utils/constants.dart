// ---------------------------------------------------------------
// constants.dart
//
// PURPOSE: Central place for app-wide constants such as Firestore
// collection names, default values, and configuration strings.
// ---------------------------------------------------------------

/// Firestore collection paths.
class FirestorePaths {
  FirestorePaths._(); // prevent instantiation

  /// Top-level users collection.
  static const String users = 'users';

  /// Service categories collection.
  static const String services = 'services';

  /// Service providers collection.
  static const String providers = 'providers';
}

/// User role identifiers stored in the Firestore `role` field.
class UserRoles {
  UserRoles._();

  static const String customer = 'customer';
  static const String provider = 'provider';
}

/// App-wide UI constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'LocalServe';
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 60;
}

// ---------------------------------------------------------------
// service_provider.dart
//
// PURPOSE: Data model for a service provider stored in the
// Firestore `providers` collection.  Each provider belongs to a
// category and has ratings, pricing, location, availability, and
// profile information.
// ---------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a service provider from the Firestore `providers` collection.
class ServiceProvider {
  final String id;
  final String name;
  final String categoryId;
  final double rating;
  final int totalReviews;
  final double hourlyRate;
  final GeoPoint location;
  final String city;
  final bool available;
  final String photoUrl;
  final String about;

  const ServiceProvider({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.rating,
    required this.totalReviews,
    required this.hourlyRate,
    required this.location,
    required this.city,
    required this.available,
    required this.photoUrl,
    required this.about,
  });

  // ── Firestore serialization ────────────────────────────────

  /// Creates a [ServiceProvider] from a Firestore document snapshot.
  factory ServiceProvider.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return ServiceProvider(
      id: doc.id,
      name: data['name'] as String,
      categoryId: data['categoryId'] as String,
      rating: (data['rating'] as num).toDouble(),
      totalReviews: data['totalReviews'] as int? ?? 0,
      hourlyRate: (data['hourlyRate'] as num).toDouble(),
      location: data['location'] as GeoPoint,
      city: data['city'] as String? ?? '',
      available: data['available'] as bool? ?? true,
      photoUrl: data['photoUrl'] as String? ?? '',
      about: data['about'] as String? ?? '',
    );
  }

  /// Converts this provider to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'categoryId': categoryId,
      'rating': rating,
      'totalReviews': totalReviews,
      'hourlyRate': hourlyRate,
      'location': location,
      'city': city,
      'available': available,
      'photoUrl': photoUrl,
      'about': about,
    };
  }
}

// ---------------------------------------------------------------
// services_repository.dart
//
// PURPOSE: Data layer for service categories and providers.
// Wraps Firestore queries for the `services` and `providers`
// collections.  Returns streams for real-time updates and
// futures for one-off reads.
// ---------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/constants.dart';
import '../../../models/service_category.dart';
import '../../../models/service_provider.dart';

/// Repository that handles Firestore reads for service categories
/// and service providers.
class ServicesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Categories ─────────────────────────────────────────────

  /// Streams all service categories from the `services` collection.
  /// The list updates in real-time when documents are added/removed.
  Stream<List<ServiceCategory>> getCategories() {
    return _firestore
        .collection(FirestorePaths.services)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceCategory.fromFirestore(doc))
            .toList());
  }

  // ── Providers ──────────────────────────────────────────────

  /// Streams all providers that belong to [categoryId].
  /// Results are ordered by rating (highest first).
  Stream<List<ServiceProvider>> getProvidersByCategory(String categoryId) {
    return _firestore
        .collection(FirestorePaths.providers)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceProvider.fromFirestore(doc))
            .toList());
  }

  /// Fetches a single provider document by [providerId].
  /// Throws if the document does not exist.
  Future<ServiceProvider> getProvider(String providerId) async {
    final doc = await _firestore
        .collection(FirestorePaths.providers)
        .doc(providerId)
        .get();

    if (!doc.exists) {
      throw Exception('Provider not found');
    }

    return ServiceProvider.fromFirestore(doc);
  }
}

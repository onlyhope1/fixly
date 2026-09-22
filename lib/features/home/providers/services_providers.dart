// ---------------------------------------------------------------
// services_providers.dart
//
// PURPOSE: Riverpod providers that expose service categories
// and provider data to the widget tree.  Screens watch these
// providers to reactively display Firestore data without
// directly depending on the repository.
// ---------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/service_category.dart';
import '../../../models/service_provider.dart';
import '../../../models/review.dart';
import '../data/services_repository.dart';

/// Provides a singleton [ServicesRepository] instance.
final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepository();
});

/// Streams all service categories from Firestore.
/// The home screen watches this to build the category grid.
final categoriesProvider = StreamProvider<List<ServiceCategory>>((ref) {
  return ref.watch(servicesRepositoryProvider).getCategories();
});

/// Streams providers filtered by [categoryId].
/// Uses `.family` so each category gets its own stream.
final providersByCategoryProvider =
    StreamProvider.family<List<ServiceProvider>, String>(
        (ref, categoryId) {
  return ref
      .watch(servicesRepositoryProvider)
      .getProvidersByCategory(categoryId);
});

/// Fetches a single provider's details by [providerId].
/// Uses `.family` so each provider detail screen gets its own future.
final providerDetailProvider =
    FutureProvider.family<ServiceProvider, String>((ref, providerId) {
  return ref.watch(servicesRepositoryProvider).getProvider(providerId);
});

/// Streams reviews for a provider.
final providerReviewsProvider =
    StreamProvider.family<List<Review>, String>((ref, providerId) {
  return ref.watch(servicesRepositoryProvider).getProviderReviews(providerId);
});


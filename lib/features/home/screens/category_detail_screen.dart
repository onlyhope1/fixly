// ---------------------------------------------------------------
// category_detail_screen.dart
//
// PURPOSE: Shows a list of service providers in a specific
// category.  Each provider card displays photo, name, rating,
// hourly rate, and city.  Tapping a card navigates to the
// provider's full detail screen.  Handles loading, empty, and
// error states.
// ---------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../models/service_provider.dart';
import '../providers/services_providers.dart';

/// Screen listing all providers in a given service category.
class CategoryDetailScreen extends ConsumerWidget {
  /// The Firestore document ID of the category.
  final String categoryId;

  /// The human-readable category name (for the AppBar title).
  final String categoryName;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync =
        ref.watch(providersByCategoryProvider(categoryId));

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: providersAsync.when(
        // ── Loading state ──────────────────────────────────────
        loading: () => const LoadingIndicator(),

        // ── Error state ────────────────────────────────────────
        error: (error, _) => ErrorView(
          message: 'Failed to load providers',
          onRetry: () =>
              ref.invalidate(providersByCategoryProvider(categoryId)),
        ),

        // ── Data state ─────────────────────────────────────────
        data: (providers) {
          if (providers.isEmpty) {
            return EmptyView(
              icon: Icons.person_search_rounded,
              title: 'No providers found',
              subtitle:
                  'No $categoryName providers are available right now.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: providers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final provider = providers[index];
              return _ProviderCard(
                provider: provider,
                onTap: () => context.push(
                  '/home/provider/${provider.id}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Private helper widget ────────────────────────────────────────

/// Card showing a provider's photo, name, rating, price, and city.
class _ProviderCard extends StatelessWidget {
  final ServiceProvider provider;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ── Provider photo ──────────────────────────────
              CircleAvatar(
                radius: 30,
                backgroundImage: provider.photoUrl.isNotEmpty
                    ? NetworkImage(provider.photoUrl)
                    : null,
                child: provider.photoUrl.isEmpty
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
              const SizedBox(width: 12),

              // ── Provider info ───────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      provider.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Rating row
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          provider.rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            ' (${provider.totalReviews} reviews)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // City
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            provider.city,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Price and availability ──────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\u20B9${provider.hourlyRate.toInt()}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    '/hr',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Availability badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: provider.available
                          ? Colors.green.withValues(alpha: 0.12)
                          : theme.colorScheme.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      provider.available ? 'Available' : 'Busy',
                      style: TextStyle(
                        fontSize: 11,
                        color: provider.available
                            ? Colors.green[700]
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

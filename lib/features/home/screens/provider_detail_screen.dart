// ---------------------------------------------------------------
// provider_detail_screen.dart
//
// PURPOSE: Full profile view for a service provider.  Shows the
// provider's photo, name, rating, hourly rate, about section,
// availability status, and a placeholder reviews section.
// A "Book Now" button at the bottom shows a snackbar for now.
// ---------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/services_providers.dart';

/// Full detail screen for a single service provider.
class ProviderDetailScreen extends ConsumerWidget {
  /// The Firestore document ID of the provider.
  final String providerId;

  const ProviderDetailScreen({
    super.key,
    required this.providerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerAsync = ref.watch(providerDetailProvider(providerId));

    return providerAsync.when(
      // ── Loading state ────────────────────────────────────────
      loading: () => const Scaffold(body: LoadingIndicator()),

      // ── Error state ──────────────────────────────────────────
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          message: 'Failed to load provider details',
          onRetry: () =>
              ref.invalidate(providerDetailProvider(providerId)),
        ),
      ),

      // ── Data state ───────────────────────────────────────────
      data: (provider) {
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(title: Text(provider.name)),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero section ─────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  child: Column(
                    children: [
                      // Provider photo
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: provider.photoUrl.isNotEmpty
                            ? NetworkImage(provider.photoUrl)
                            : null,
                        child: provider.photoUrl.isEmpty
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Name
                      Text(
                        provider.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Rating row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_rounded,
                              color: Colors.amber[700], size: 20),
                          const SizedBox(width: 4),
                          Text(
                            provider.rating.toStringAsFixed(1),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${provider.totalReviews} reviews)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Location
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            provider.city,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Info chips ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.currency_rupee,
                          label:
                              '\u20B9${provider.hourlyRate.toInt()}/hr',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoChip(
                          icon: provider.available
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          label:
                              provider.available ? 'Available' : 'Busy',
                          color: provider.available
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── About section ────────────────────────────────
                if (provider.about.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'About',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Text(
                      provider.about,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],

                const Divider(),

                // ── Reviews section (placeholder) ────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Reviews',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ..._placeholderReviews
                    .map((review) => _ReviewCard(review: review)),

                // Space for the Book Now button
                const SizedBox(height: 80),
              ],
            ),
          ),

          // ── Book Now button ─────────────────────────────────
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking feature coming soon!'),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Book Now'),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Placeholder review data ──────────────────────────────────────

/// A simple data holder for placeholder reviews.
class _Review {
  final String name;
  final double rating;
  final String comment;
  final String date;

  const _Review({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

/// Three hardcoded reviews to populate the reviews section.
const _placeholderReviews = [
  _Review(
    name: 'Amit S.',
    rating: 5.0,
    comment: 'Excellent work! Very professional and finished on time.',
    date: '2 days ago',
  ),
  _Review(
    name: 'Priya M.',
    rating: 4.0,
    comment: 'Good service overall. Would recommend to others.',
    date: '1 week ago',
  ),
  _Review(
    name: 'Rahul K.',
    rating: 4.5,
    comment: 'Very skilled and polite. Fair pricing too.',
    date: '2 weeks ago',
  ),
];

// ── Helper widgets ───────────────────────────────────────────────

/// A chip showing an icon and label (used for price and availability).
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: chipColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// A card displaying a single review with name, rating stars,
/// comment, and date.
class _ReviewCard extends StatelessWidget {
  final _Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    review.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    review.date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Star rating
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating.floor()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 16,
                    color: Colors.amber[700],
                  );
                }),
              ),
              const SizedBox(height: 8),

              // Comment text
              Text(
                review.comment,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

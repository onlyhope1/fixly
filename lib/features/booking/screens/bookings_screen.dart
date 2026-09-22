// ---------------------------------------------------------------
// bookings_screen.dart
//
// PURPOSE: Customer "My Bookings" tab.  Displays all bookings
// grouped into Upcoming (pending + accepted) and Past (completed
// + rejected) using a TabBar.  Real-time Firestore streams keep
// the list updated as booking statuses change.
// ---------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/constants.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../models/booking.dart';
import '../../../models/review.dart';
import '../providers/booking_providers.dart';

/// Customer's "My Bookings" tab with Upcoming and Past sections.
class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(customerBookingsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: bookingsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (error, _) => ErrorView(
            message: 'Failed to load bookings',
            onRetry: () => ref.invalidate(customerBookingsProvider),
          ),
          data: (bookings) {
            final upcoming = bookings
                .where((b) =>
                    b.status == BookingStatus.pending ||
                    b.status == BookingStatus.accepted)
                .toList();
            final past = bookings
                .where((b) =>
                    b.status == BookingStatus.completed ||
                    b.status == BookingStatus.rejected)
                .toList();

            return TabBarView(
              children: [
                _BookingList(
                  bookings: upcoming,
                  emptyMessage: 'No upcoming bookings',
                  emptySubtitle: 'Book a service to get started!',
                ),
                _BookingList(
                  bookings: past,
                  emptyMessage: 'No past bookings',
                  emptySubtitle: 'Completed bookings will appear here.',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A scrollable list of booking cards with empty state handling.
class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  final String emptyMessage;
  final String emptySubtitle;

  const _BookingList({
    required this.bookings,
    required this.emptyMessage,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyView(
        icon: Icons.calendar_today_outlined,
        title: emptyMessage,
        subtitle: emptySubtitle,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _BookingCard(booking: bookings[index]),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service + provider name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${booking.serviceName} — ${booking.providerName}',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 8),

            // Date and time
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${DateFormat('EEE, MMM d').format(booking.scheduledTime)} '
                    'at ${DateFormat('h:mm a').format(booking.scheduledTime)} '
                    '(${booking.durationHours}hr${booking.durationHours > 1 ? 's' : ''})',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Address
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking.address,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Price and Review Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${booking.price.toInt()}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (booking.status == BookingStatus.completed && !booking.isRated)
                  OutlinedButton(
                    onPressed: () {
                      _showReviewDialog(context, ref, booking);
                    },
                    child: const Text('Leave a Review'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context, WidgetRef ref, Booking booking) {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Leave a Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final review = Review(
                      id: '',
                      bookingId: booking.id,
                      customerId: booking.customerId,
                      customerName: 'Customer', // Would fetch actual name in real app, assuming dummy here or checking models
                      rating: rating,
                      comment: commentController.text,
                      createdAt: DateTime.now(),
                    );
                    await ref
                        .read(bookingRepositoryProvider)
                        .submitReview(providerId: booking.providerId, review: review);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// A coloured status badge (Pending=orange, Accepted=green, etc.).
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status) {
      BookingStatus.pending => (Colors.orange.shade50, Colors.orange.shade700),
      BookingStatus.accepted => (Colors.green.shade50, Colors.green.shade700),
      BookingStatus.rejected => (Colors.red.shade50, Colors.red.shade700),
      BookingStatus.completed => (Colors.blue.shade50, Colors.blue.shade700),
      _ => (Colors.grey.shade100, Colors.grey.shade700),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

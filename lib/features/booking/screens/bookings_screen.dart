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

/// Card showing a single booking's details and status badge.
class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
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
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('EEE, MMM d').format(booking.scheduledTime)} '
                  'at ${DateFormat('h:mm a').format(booking.scheduledTime)} '
                  '(${booking.durationHours}hr${booking.durationHours > 1 ? 's' : ''})',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Address
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking.address,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Price
            Text(
              '₹${booking.price.toInt()}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
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

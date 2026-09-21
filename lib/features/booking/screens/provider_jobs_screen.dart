// ---------------------------------------------------------------
// provider_jobs_screen.dart
//
// PURPOSE: Provider's "My Jobs" tab.  Shows accepted bookings
// sorted by date, with a "Mark Complete" button for jobs whose
// scheduled time has passed.
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

/// Provider's "My Jobs" tab showing accepted and completed bookings.
class ProviderJobsScreen extends ConsumerWidget {
  const ProviderJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(providerAcceptedBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs'),
        centerTitle: false,
      ),
      body: jobsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: 'Failed to load jobs',
          onRetry: () =>
              ref.invalidate(providerAcceptedBookingsProvider),
        ),
        data: (jobs) {
          if (jobs.isEmpty) {
            return const EmptyView(
              icon: Icons.work_outline_rounded,
              title: 'No jobs yet',
              subtitle: 'Accepted bookings will appear here.',
            );
          }

          // Split into upcoming and past-due.
          final now = DateTime.now();
          final upcoming = jobs
              .where((j) => j.endTime.isAfter(now))
              .toList();
          final pastDue = jobs
              .where((j) => j.endTime.isBefore(now))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Upcoming',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (upcoming.isNotEmpty)
                ...upcoming.map((j) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _JobCard(booking: j, showComplete: false),
                    ))
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text('No upcoming jobs.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              
              const SizedBox(height: 8),
              Text('Ready to Complete',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (pastDue.isNotEmpty)
                ...pastDue.map((j) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _JobCard(booking: j, showComplete: true),
                    ))
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text('No past due jobs.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Card showing a job with optional "Mark Complete" button.
class _JobCard extends ConsumerStatefulWidget {
  final Booking booking;
  final bool showComplete;

  const _JobCard({required this.booking, required this.showComplete});

  @override
  ConsumerState<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends ConsumerState<_JobCard> {
  bool _isProcessing = false;

  Future<void> _markComplete() async {
    setState(() => _isProcessing = true);
    try {
      await ref
          .read(bookingRepositoryProvider)
          .updateBookingStatus(
              widget.booking.id, BookingStatus.completed);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final booking = widget.booking;

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
            Text(booking.serviceName,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${DateFormat('EEE, MMM d').format(booking.scheduledTime)} '
                    'at ${DateFormat('h:mm a').format(booking.scheduledTime)} '
                    '(${booking.durationHours}hr${booking.durationHours > 1 ? 's' : ''})',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(booking.address,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(booking.customerPhone,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '\u20B9${booking.price.toInt()}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                if (widget.showComplete)
                  FilledButton.icon(
                    onPressed:
                        _isProcessing ? null : _markComplete,
                    icon: _isProcessing
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: const Text('Mark Complete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

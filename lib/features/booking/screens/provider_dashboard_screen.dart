// ---------------------------------------------------------------
// provider_dashboard_screen.dart
//
// PURPOSE: Provider's home tab showing incoming pending booking
// requests.  Each request has Accept/Reject buttons.  Accept
// checks for schedule conflicts (double-booking) and warns the
// provider before allowing them to proceed.
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

/// Provider's dashboard \u2014 shows incoming pending booking requests.
class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(providerPendingBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: false,
      ),
      body: pendingAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: 'Failed to load requests',
          onRetry: () =>
              ref.invalidate(providerPendingBookingsProvider),
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return const EmptyView(
              icon: Icons.inbox_rounded,
              title: 'No pending requests',
              subtitle: 'New booking requests will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _RequestCard(booking: bookings[index]);
            },
          );
        },
      ),
    );
  }
}

/// Card showing an incoming booking request with Accept/Reject buttons.
class _RequestCard extends ConsumerStatefulWidget {
  final Booking booking;
  const _RequestCard({required this.booking});

  @override
  ConsumerState<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<_RequestCard> {
  bool _isProcessing = false;

  /// Accepts the booking after checking for double-booking conflicts.
  Future<void> _acceptBooking() async {
    setState(() => _isProcessing = true);

    try {
      final repo = ref.read(bookingRepositoryProvider);

      // Check for schedule conflicts.
      final conflicts = await repo.checkDoubleBooking(
        providerId: widget.booking.providerId,
        scheduledTime: widget.booking.scheduledTime,
        durationHours: widget.booking.durationHours,
      );

      if (!mounted) return;

      if (conflicts.isNotEmpty) {
        // Show double-booking warning dialog.
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange),
                SizedBox(width: 8),
                Text('Schedule Conflict'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'This booking overlaps with an accepted job:'),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: conflicts.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '\u2022 ${DateFormat('MMM d, h:mm a').format(c.scheduledTime)} '
                          '(${c.durationHours}hr) \u2014 ${c.serviceName}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Do you still want to accept?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Accept Anyway'),
              ),
            ],
          ),
        );

        if (proceed != true) {
          setState(() => _isProcessing = false);
          return;
        }
      }

      // Accept the booking.
      await repo.updateBookingStatus(
          widget.booking.id, BookingStatus.accepted);
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

  /// Rejects the booking.
  Future<void> _rejectBooking() async {
    setState(() => _isProcessing = true);
    try {
      await ref
          .read(bookingRepositoryProvider)
          .updateBookingStatus(
              widget.booking.id, BookingStatus.rejected);
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
            // Customer phone
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(booking.customerPhone,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),

            // Service name
            Text(booking.serviceName,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Date and time
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

            // Address
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

            // Notes
            if (booking.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.note_outlined,
                      size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(booking.notes,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),

            // Price
            Text(
              '\u20B9${booking.price.toInt()}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Accept / Reject buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _rejectBooking,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isProcessing ? null : _acceptBooking,
                    icon: _isProcessing
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

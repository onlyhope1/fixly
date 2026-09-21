// ---------------------------------------------------------------
// booking_form_screen.dart
//
// PURPOSE: Form screen where a customer selects a date, time,
// duration, enters their address, and confirms a booking.
// Calculates price automatically from hourly rate x duration.
// Uses geolocator for optional "Use My Location" feature.
// ---------------------------------------------------------------

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/utils/constants.dart';
import '../../../models/booking.dart';
import '../providers/booking_providers.dart';

/// Booking form screen where customers fill in appointment details.
class BookingFormScreen extends ConsumerStatefulWidget {
  final String providerId;
  final String providerName;
  final double hourlyRate;
  final String serviceId;

  const BookingFormScreen({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.hourlyRate,
    required this.serviceId,
  });

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  late Razorpay _razorpay;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _durationHours = AppConstants.defaultDurationHours;
  bool _isSubmitting = false;
  bool _isGettingLocation = false;
  String? _pendingBookingId;

  /// Capitalizes the service ID for display (e.g. "plumbing" -> "Plumbing").
  String get _serviceName {
    if (widget.serviceId.isEmpty) return 'Service';
    return widget.serviceId[0].toUpperCase() + widget.serviceId.substring(1);
  }

  /// Total price = hourly rate x duration.
  double get _totalPrice => widget.hourlyRate * _durationHours;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ── Razorpay handlers ──────────────────────────────────────

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_pendingBookingId == null) return;
    try {
      await ref
          .read(bookingRepositoryProvider)
          .updateBookingStatus(_pendingBookingId!, BookingStatus.pending);
      if (!mounted) return;
      _showSnackBar('Payment successful! Booking request sent.');
      context.pop();
    } catch (e) {
      _showSnackBar('Failed to update booking status: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showSnackBar('Payment failed. Try again from your Bookings tab.');
    if (mounted) {
      setState(() => _isSubmitting = false);
      context.pop(); // Pop to home, they can retry from Bookings tab later
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackBar('External wallet selected: ${response.walletName}');
  }

  // ── Date picker ───────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ── Time picker ───────────────────────────────────────────

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ── Location ──────────────────────────────────────────────

  Future<void> _useMyLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permission permanently denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      _addressController.text =
          'Lat: ${position.latitude.toStringAsFixed(4)}, '
          'Lng: ${position.longitude.toStringAsFixed(4)}';
    } catch (e) {
      _showSnackBar('Could not get location');
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ── Submit booking ────────────────────────────────────────

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      _showSnackBar('Please select a date and time');
      return;
    }

    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser!;
    final scheduledTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final booking = Booking(
      id: '',
      customerId: user.uid,
      providerId: widget.providerId,
      serviceId: widget.serviceId,
      serviceName: _serviceName,
      providerName: widget.providerName,
      customerPhone: user.phoneNumber ?? '',
      scheduledTime: scheduledTime,
      durationHours: _durationHours,
      status: BookingStatus.pendingPayment,
      address: _addressController.text.trim(),
      price: _totalPrice,
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      _pendingBookingId = await ref.read(bookingRepositoryProvider).createBooking(booking);

      var options = {
        'key': 'rzp_test_YourTestKey',
        'amount': (_totalPrice * 100).toInt(),
        'name': 'LocalServe',
        'description': 'Booking for $_serviceName',
        'prefill': {'contact': user.phoneNumber ?? '', 'email': ''},
        'notes': {'bookingId': _pendingBookingId}
      };
      
      _razorpay.open(options);
    } catch (e) {
      _showSnackBar('Failed to create booking: $e');
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.providerName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Service info ─────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.home_repair_service,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_serviceName,
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            Text(
                              '₹${widget.hourlyRate.toInt()}/hr',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Date picker ──────────────────────────────────
              Text('Select Date',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _selectedDate != null
                      ? DateFormat('EEE, MMM d, yyyy').format(_selectedDate!)
                      : 'Choose a date',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(height: 20),

              // ── Time picker ──────────────────────────────────
              Text('Select Time',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _pickTime,
                icon: const Icon(Icons.access_time),
                label: Text(
                  _selectedTime != null
                      ? _selectedTime!.format(context)
                      : 'Choose a time',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(height: 20),

              // ── Duration selector ────────────────────────────
              Text('Duration',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _durationHours,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.timer_outlined),
                ),
                items: [1, 2, 3, 4].map((h) {
                  return DropdownMenuItem(
                    value: h,
                    child: Text('$h hour${h > 1 ? 's' : ''}'),
                  );
                }).toList(),
                onChanged: _isSubmitting ? null : (val) {
                  if (val != null) setState(() => _durationHours = val);
                },
              ),
              const SizedBox(height: 20),

              // ── Address input ────────────────────────────────
              Text('Your Address',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                enabled: !_isSubmitting,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Address is required' : null,
                decoration: InputDecoration(
                  hintText: 'Enter your address',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: (_isGettingLocation || _isSubmitting) ? null : _useMyLocation,
                icon: _isGettingLocation
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: const Text('Use My Location'),
              ),
              const SizedBox(height: 20),

              // ── Notes ────────────────────────────────────────
              Text('Notes (optional)',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  hintText: 'Any special requests...',
                  prefixIcon: const Icon(Icons.note_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // ── Price summary ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price Summary',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            '₹${widget.hourlyRate.toInt()}/hr × $_durationHours hr${_durationHours > 1 ? 's' : ''}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${_totalPrice.toInt()}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Confirm button ───────────────────────────────
              FilledButton(
                onPressed: _isSubmitting ? null : _confirmBooking,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Confirm & Pay'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}


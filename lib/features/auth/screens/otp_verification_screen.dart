// ---------------------------------------------------------------
// otp_verification_screen.dart
//
// PURPOSE: Accepts the 6-digit OTP sent to the user's phone.
// Uses the `pinput` package for a polished OTP input field.
// On successful verification, checks Firestore for an existing
// user doc — if none exists, routes to role selection; otherwise
// routes to home.
// ---------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../core/utils/constants.dart';
import '../providers/auth_providers.dart';

/// Screen for entering the SMS verification code.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  /// The verification ID returned by Firebase after sending the OTP.
  final String verificationId;

  /// The phone number the OTP was sent to (for display).
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  /// Verifies the entered OTP and navigates accordingly.
  Future<void> _verifyOtp(String otp) async {
    if (otp.length < AppConstants.otpLength) return;

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);

      // Sign in with the OTP.
      final credential = await authRepo.signInWithOtp(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      if (!mounted) return;

      // Check if a Firestore profile already exists.
      final appUser = await authRepo.getUser(credential.user!.uid);

      if (!mounted) return;

      if (appUser == null) {
        // First-time user → choose a role.
        context.go('/role-selection');
      } else {
        // Returning user → go home.
        context.go('/home');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Pinput theme for OTP boxes.
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: theme.textTheme.headlineSmall,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ── Instruction text ──────────────────────────
              Text(
                'Enter the 6-digit code sent to',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                widget.phoneNumber,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // ── OTP input ─────────────────────────────────
              Pinput(
                controller: _otpController,
                length: AppConstants.otpLength,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyDecorationWith(
                  border: Border.all(color: theme.colorScheme.primary, width: 2),
                ),
                onCompleted: _verifyOtp,
              ),
              const SizedBox(height: 32),

              // ── Verify button ─────────────────────────────
              if (_isLoading)
                const CircularProgressIndicator()
              else
                FilledButton(
                  onPressed: () => _verifyOtp(_otpController.text),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Verify'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

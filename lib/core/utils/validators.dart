// ---------------------------------------------------------------
// validators.dart
//
// PURPOSE: Reusable input-validation helpers.
// Currently contains phone-number validation; extend as needed.
// ---------------------------------------------------------------

/// Validates an Indian-format phone number (10 digits, optionally
/// prefixed with +91).
class Validators {
  Validators._();

  /// Returns an error message if [value] is not a valid phone number,
  /// or `null` if it is valid.
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Strip country code and spaces for validation.
    final digits = value.replaceAll(RegExp(r'[\s\-+]'), '');

    // Allow 10 digits or 12 digits (with 91 prefix).
    if (digits.length == 12 && digits.startsWith('91')) return null;
    if (digits.length == 10) return null;

    return 'Enter a valid 10-digit phone number';
  }
}

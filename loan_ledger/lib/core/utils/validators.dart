/// Form validation utilities for Loan Ledger.
class Validators {
  Validators._();

  /// Validate required field
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate full name (at least 2 characters)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validate phone number (10 digits for India)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Validate amount (positive number)
  static String? amount(String? value, {String fieldName = 'Amount'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      return 'Enter a valid number';
    }
    if (amount <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  /// Validate interest rate (0-100%)
  static String? interestRate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Interest rate is required';
    }
    final rate = double.tryParse(value);
    if (rate == null) {
      return 'Enter a valid number';
    }
    if (rate < 0 || rate > 100) {
      return 'Rate must be between 0% and 100%';
    }
    return null;
  }

  /// Validate PIN (4-6 digits)
  static String? pin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PIN is required';
    }
    if (!RegExp(r'^\d{4,6}$').hasMatch(value)) {
      return 'PIN must be 4-6 digits';
    }
    return null;
  }

  /// Validate payment amount against remaining balance
  static String? paymentAmount(String? value, double remainingBalance) {
    final baseError = amount(value, fieldName: 'Payment amount');
    if (baseError != null) return baseError;

    final payment = double.tryParse(value!.replaceAll(',', ''))!;
    if (payment > remainingBalance) {
      return 'Cannot exceed remaining balance';
    }
    return null;
  }
}

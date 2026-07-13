import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Currency formatting utilities for consistent money display.
class CurrencyFormatter {
  CurrencyFormatter._();

  static String _symbol = AppConstants.defaultCurrency;

  /// Update the currency symbol (called from settings).
  static void setSymbol(String symbol) {
    _symbol = symbol;
  }

  /// Format a number as currency: ₹1,23,456.00
  static String format(double amount) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    return '$_symbol${formatter.format(amount)}';
  }

  /// Format without decimals: ₹1,23,456
  static String formatCompact(double amount) {
    final formatter = NumberFormat('#,##,##0', 'en_IN');
    return '$_symbol${formatter.format(amount)}';
  }

  /// Format with abbreviation: ₹1.2L, ₹50K
  static String formatShort(double amount) {
    if (amount >= 10000000) {
      return '$_symbol${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '$_symbol${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '$_symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formatCompact(amount);
  }

  /// Format as plain number string (for input fields).
  static String formatPlain(double amount) {
    if (amount == amount.truncateToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }
}

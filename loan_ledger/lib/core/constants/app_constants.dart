/// App-wide constants for Loan Ledger.
class AppConstants {
  AppConstants._();

  // ─── App Info ──────────────────────────────────────────
  static const String appName = 'Loan Ledger';
  static const String appVersion = '1.0.0';

  // ─── Hive Box Names ────────────────────────────────────
  static const String customersBox = 'customers';
  static const String loansBox = 'loans';
  static const String paymentsBox = 'payments';
  static const String settingsBox = 'settings';

  // ─── Settings Keys ────────────────────────────────────
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String pinEnabledKey = 'pin_enabled';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String currencySymbolKey = 'currency_symbol';
  static const String lastSyncKey = 'last_sync';

  // ─── Default Values ───────────────────────────────────
  static const String defaultCurrency = '₹';
  static const String defaultLanguage = 'en';
  static const double defaultInterestRate = 2.0; // 2% monthly

  // ─── Animation Durations ──────────────────────────────
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 350);

  // ─── Layout ───────────────────────────────────────────
  static const double horizontalPadding = 20.0;
  static const double verticalPadding = 16.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 14.0;
  static const double inputRadius = 12.0;

  // ─── Limits ───────────────────────────────────────────
  static const int maxSearchResults = 50;
  static const int recentTransactionsLimit = 10;
  static const int upcomingDuesLimit = 5;
  static const int searchDebounceMs = 300;
}

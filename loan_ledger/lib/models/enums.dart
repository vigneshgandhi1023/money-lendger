/// Enumerations used across Loan Ledger.

/// Type of interest calculation for a loan.
enum InterestType {
  /// Fixed percentage per month on the principal amount.
  monthly('Monthly', 'per month'),

  /// Fixed percentage per year on the principal amount.
  yearly('Yearly', 'per year'),

  /// One-time flat interest applied to the total loan.
  flat('Flat', 'one-time');

  const InterestType(this.label, this.suffix);

  final String label;
  final String suffix;
}

/// Current status of a loan.
enum LoanStatus {
  /// Loan is active and payments are being collected.
  active('Active'),

  /// Loan has been fully repaid.
  closed('Closed'),

  /// Loan payment is past the due date.
  overdue('Overdue');

  const LoanStatus(this.label);

  final String label;
}

/// Type of payment received.
enum PaymentType {
  /// Partial payment — some amount of the outstanding balance.
  partial('Partial'),

  /// Full payment — clears the entire outstanding balance.
  full('Full');

  const PaymentType(this.label);

  final String label;
}

/// Theme mode preference.
enum AppThemeMode {
  system('System'),
  light('Light'),
  dark('Dark');

  const AppThemeMode(this.label);

  final String label;
}

/// Report period for collection reports.
enum ReportPeriod {
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly');

  const ReportPeriod(this.label);

  final String label;
}

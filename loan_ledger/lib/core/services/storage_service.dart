import 'package:hive_flutter/hive_flutter.dart';

import '../../models/customer.dart';
import '../../models/loan.dart';
import '../../models/payment.dart';
import '../constants/app_constants.dart';

/// Offline-first local storage service using Hive.
///
/// Manages all CRUD operations for customers, loans, and payments.
/// Data persists locally and syncs to Firebase when available.
class StorageService {
  StorageService._();

  static late Box<Customer> _customersBox;
  static late Box<Loan> _loansBox;
  static late Box<Payment> _paymentsBox;
  static late Box<dynamic> _settingsBox;

  /// Initialize Hive and register type adapters.
  static Future<void> initialize() async {
    // Register adapters
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(LoanAdapter());
    Hive.registerAdapter(PaymentAdapter());

    // Open boxes
    _customersBox = await Hive.openBox<Customer>(AppConstants.customersBox);
    _loansBox = await Hive.openBox<Loan>(AppConstants.loansBox);
    _paymentsBox = await Hive.openBox<Payment>(AppConstants.paymentsBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }

  // ─── Customers ─────────────────────────────────────────

  static Box<Customer> get customersBox => _customersBox;

  static List<Customer> getAllCustomers() {
    return _customersBox.values.toList()
      ..sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
  }

  static Customer? getCustomer(String id) {
    return _customersBox.get(id);
  }

  static Future<void> saveCustomer(Customer customer) async {
    await _customersBox.put(customer.id, customer);
  }

  static Future<void> deleteCustomer(String id) async {
    // Also delete associated loans and payments
    final loans = getLoansForCustomer(id);
    for (final loan in loans) {
      await deletePaymentsForLoan(loan.id);
      await _loansBox.delete(loan.id);
    }
    await _customersBox.delete(id);
  }

  static List<Customer> searchCustomers(String query) {
    final lowerQuery = query.toLowerCase();
    return _customersBox.values.where((customer) {
      return customer.fullName.toLowerCase().contains(lowerQuery) ||
          customer.phoneNumber.contains(query);
    }).toList();
  }

  // ─── Loans ─────────────────────────────────────────────

  static Box<Loan> get loansBox => _loansBox;

  static List<Loan> getAllLoans() {
    return _loansBox.values.toList()
      ..sort((a, b) => b.loanDate.compareTo(a.loanDate));
  }

  static Loan? getLoan(String id) {
    return _loansBox.get(id);
  }

  static List<Loan> getLoansForCustomer(String customerId) {
    return _loansBox.values
        .where((loan) => loan.customerId == customerId)
        .toList()
      ..sort((a, b) => b.loanDate.compareTo(a.loanDate));
  }

  static List<Loan> getActiveLoans() {
    return _loansBox.values
        .where((loan) => loan.statusName == 'active' || loan.statusName == 'overdue')
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  static List<Loan> getOverdueLoans() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _loansBox.values.where((loan) {
      if (loan.statusName == 'closed') return false;
      final due = DateTime(loan.dueDate.year, loan.dueDate.month, loan.dueDate.day);
      return due.isBefore(today);
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  static List<Loan> getUpcomingDueLoans({int days = 7}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final limit = today.add(Duration(days: days));
    return _loansBox.values.where((loan) {
      if (loan.statusName == 'closed') return false;
      final due = DateTime(loan.dueDate.year, loan.dueDate.month, loan.dueDate.day);
      return !due.isBefore(today) && !due.isAfter(limit);
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  static Future<void> saveLoan(Loan loan) async {
    await _loansBox.put(loan.id, loan);
  }

  static Future<void> deleteLoan(String id) async {
    await deletePaymentsForLoan(id);
    await _loansBox.delete(id);
  }

  // ─── Payments ──────────────────────────────────────────

  static Box<Payment> get paymentsBox => _paymentsBox;

  static List<Payment> getAllPayments() {
    return _paymentsBox.values.toList()
      ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
  }

  static List<Payment> getPaymentsForLoan(String loanId) {
    return _paymentsBox.values
        .where((p) => p.loanId == loanId)
        .toList()
      ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
  }

  static List<Payment> getPaymentsForCustomer(String customerId) {
    return _paymentsBox.values
        .where((p) => p.customerId == customerId)
        .toList()
      ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
  }

  static List<Payment> getPaymentsForDate(DateTime date) {
    return _paymentsBox.values.where((p) {
      return p.paymentDate.year == date.year &&
          p.paymentDate.month == date.month &&
          p.paymentDate.day == date.day;
    }).toList();
  }

  static List<Payment> getPaymentsInRange(DateTime start, DateTime end) {
    return _paymentsBox.values.where((p) {
      return !p.paymentDate.isBefore(start) && !p.paymentDate.isAfter(end);
    }).toList()
      ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
  }

  static Future<void> savePayment(Payment payment) async {
    await _paymentsBox.put(payment.id, payment);
  }

  static Future<void> deletePayment(String id) async {
    await _paymentsBox.delete(id);
  }

  static Future<void> deletePaymentsForLoan(String loanId) async {
    final payments = getPaymentsForLoan(loanId);
    for (final payment in payments) {
      await _paymentsBox.delete(payment.id);
    }
  }

  // ─── Settings ──────────────────────────────────────────

  static Box<dynamic> get settingsBox => _settingsBox;

  static T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  static Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  // ─── Aggregate Queries ─────────────────────────────────

  /// Total money lent across all active loans.
  static double get totalMoneyLent {
    return _loansBox.values.fold(0.0, (sum, loan) => sum + loan.loanAmount);
  }

  /// Total outstanding across all active loans.
  static double get totalOutstanding {
    return _loansBox.values
        .where((l) => l.statusName != 'closed')
        .fold(0.0, (sum, loan) => sum + loan.remainingBalance);
  }

  /// Total collected today.
  static double get collectedToday {
    final now = DateTime.now();
    return _paymentsBox.values
        .where((p) =>
            p.paymentDate.year == now.year &&
            p.paymentDate.month == now.month &&
            p.paymentDate.day == now.day)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Count of active loans.
  static int get activeLoansCount {
    return _loansBox.values
        .where((l) => l.statusName == 'active' || l.statusName == 'overdue')
        .length;
  }

  /// Count of overdue loans.
  static int get overdueLoansCount {
    return getOverdueLoans().length;
  }

  /// Total paid by a specific customer across all their loans.
  static double totalPaidByCustomer(String customerId) {
    return _paymentsBox.values
        .where((p) => p.customerId == customerId)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Total borrowed by a specific customer.
  static double totalBorrowedByCustomer(String customerId) {
    return _loansBox.values
        .where((l) => l.customerId == customerId)
        .fold(0.0, (sum, l) => sum + l.loanAmount);
  }

  // ─── Data Export ───────────────────────────────────────

  /// Export all data as a Map (for backup).
  static Map<String, dynamic> exportAllData() {
    return {
      'customers': _customersBox.values.map((c) => c.toMap()).toList(),
      'loans': _loansBox.values.map((l) => l.toMap()).toList(),
      'payments': _paymentsBox.values.map((p) => p.toMap()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  /// Import data from a backup Map.
  static Future<void> importAllData(Map<String, dynamic> data) async {
    // Clear existing data
    await _customersBox.clear();
    await _loansBox.clear();
    await _paymentsBox.clear();

    // Import customers
    final customers = (data['customers'] as List)
        .map((c) => Customer.fromMap(c as Map<String, dynamic>))
        .toList();
    for (final customer in customers) {
      await _customersBox.put(customer.id, customer);
    }

    // Import loans
    final loans = (data['loans'] as List)
        .map((l) => Loan.fromMap(l as Map<String, dynamic>))
        .toList();
    for (final loan in loans) {
      await _loansBox.put(loan.id, loan);
    }

    // Import payments
    final payments = (data['payments'] as List)
        .map((p) => Payment.fromMap(p as Map<String, dynamic>))
        .toList();
    for (final payment in payments) {
      await _paymentsBox.put(payment.id, payment);
    }
  }

  /// Clear all data (factory reset).
  static Future<void> clearAllData() async {
    await _customersBox.clear();
    await _loansBox.clear();
    await _paymentsBox.clear();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/cloud_database_service.dart';
import '../../../models/customer.dart';
import '../../loans/providers/loan_providers.dart';

/// Provider for all customers, sorted automatically by CloudDatabaseService.
final allCustomersProvider = StreamProvider<List<Customer>>((ref) {
  final db = ref.watch(cloudDatabaseProvider);
  return db.getCustomers();
});

/// Provider for a single customer by ID.
final customerProvider = StreamProvider.family<Customer?, String>((ref, id) {
  final db = ref.watch(cloudDatabaseProvider);
  return db.getCustomer(id);
});

/// Customer search results provider.
final customerSearchProvider =
    StreamProvider.family<List<Customer>, String>((ref, query) {
  final db = ref.watch(cloudDatabaseProvider);
  if (query.isEmpty) return db.getCustomers();
  
  // Basic client-side filtering for simplicity, though could be optimized
  return db.getCustomers().map((customers) => customers
      .where((c) =>
          c.fullName.toLowerCase().contains(query.toLowerCase()) ||
          c.phoneNumber.contains(query))
      .toList());
});

/// Provider for customer's total borrowed amount.
final customerTotalBorrowedProvider =
    StreamProvider.family<double, String>((ref, customerId) {
  final db = ref.watch(cloudDatabaseProvider);
  return db.getLoansForCustomer(customerId).map((loans) {
    return loans.fold(0.0, (sum, loan) => sum + loan.loanAmount);
  });
});

/// Provider for customer's total paid amount.
final customerTotalPaidProvider =
    StreamProvider.family<double, String>((ref, customerId) {
  final db = ref.watch(cloudDatabaseProvider);
  return db.getPaymentsForCustomer(customerId).map((payments) {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  });
});

/// Provider for customer's active loan count.
final customerActiveLoansCountProvider =
    StreamProvider.family<int, String>((ref, customerId) {
  final db = ref.watch(cloudDatabaseProvider);
  return db.getLoansForCustomer(customerId).map((loans) {
    return loans.where((l) => l.statusName != 'closed').length;
  });
});

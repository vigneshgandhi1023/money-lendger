import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/cloud_database_service.dart';
import '../../../models/loan.dart';

/// Provider for all loans.
final allLoansProvider = StreamProvider<List<Loan>>((ref) {
  return ref.watch(cloudDatabaseProvider).getLoans();
});

/// Provider for a single loan by ID.
final loanProvider = StreamProvider.family<Loan?, String>((ref, id) {
  return ref.watch(cloudDatabaseProvider).getLoans().map((loans) {
    try {
      return loans.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  });
});

/// Provider for loans by customer.
final customerLoansProvider =
    StreamProvider.family<List<Loan>, String>((ref, customerId) {
  return ref.watch(cloudDatabaseProvider).getLoansForCustomer(customerId);
});

/// Provider for active loans only.
final activeLoansProvider = StreamProvider<List<Loan>>((ref) {
  return ref.watch(cloudDatabaseProvider).getLoans().map((loans) =>
      loans.where((l) => l.statusName != 'closed').toList());
});

/// Provider for overdue loans.
final overdueLoansProvider = StreamProvider<List<Loan>>((ref) {
  return ref.watch(cloudDatabaseProvider).getLoans().map((loans) =>
      loans.where((l) => l.isOverdue).toList());
});

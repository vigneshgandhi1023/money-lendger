import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/cloud_database_service.dart';
import '../../../models/payment.dart';

/// Provider for all payments.
final allPaymentsProvider = StreamProvider<List<Payment>>((ref) {
  return ref.watch(cloudDatabaseProvider).getPayments();
});

/// Provider for payments by loan.
final loanPaymentsProvider =
    StreamProvider.family<List<Payment>, String>((ref, loanId) {
  return ref.watch(cloudDatabaseProvider).getPaymentsForLoan(loanId);
});

/// Provider for payments by customer.
final customerPaymentsProvider =
    StreamProvider.family<List<Payment>, String>((ref, customerId) {
  return ref.watch(cloudDatabaseProvider).getPaymentsForCustomer(customerId);
});

/// Provider for today's payments.
final todayPaymentsProvider = StreamProvider<List<Payment>>((ref) {
  final today = DateTime.now();
  return ref.watch(cloudDatabaseProvider).getPayments().map((payments) =>
      payments.where((p) =>
          p.paymentDate.year == today.year &&
          p.paymentDate.month == today.month &&
          p.paymentDate.day == today.day).toList());
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/storage_service.dart';
import '../../../models/enums.dart';
import '../../../models/loan.dart';
import '../../../models/payment.dart';

/// Selected report period.
final reportPeriodProvider =
    StateProvider<ReportPeriod>((ref) => ReportPeriod.daily);

/// Date range for the report.
final reportDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return DateTimeRange(start: today, end: today.add(const Duration(days: 1)));
});

/// Collection report data for the selected period.
final collectionReportProvider = Provider<List<Payment>>((ref) {
  final range = ref.watch(reportDateRangeProvider);
  return StorageService.getPaymentsInRange(range.start, range.end);
});

/// Total collected in the selected period.
final periodTotalProvider = Provider<double>((ref) {
  final payments = ref.watch(collectionReportProvider);
  return payments.fold(0.0, (sum, p) => sum + p.amount);
});

/// Outstanding loans provider for reports.
final outstandingLoansReportProvider = Provider<List<Loan>>((ref) {
  return StorageService.getActiveLoans();
});

/// Closed loans provider for reports.
final closedLoansReportProvider = Provider<List<Loan>>((ref) {
  return StorageService.getAllLoans()
      .where((l) => l.statusName == 'closed')
      .toList();
});

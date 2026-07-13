import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/services/cloud_database_service.dart';
import '../../../models/loan.dart';
import '../../../models/payment.dart';

/// Dashboard data model containing all KPI values.
class DashboardData {
  final double totalMoneyLent;
  final double totalOutstanding;
  final double collectedToday;
  final int activeLoans;
  final int overdueLoans;
  final List<Payment> recentTransactions;
  final List<Loan> upcomingDues;
  final List<Loan> overdueLoanslist;

  const DashboardData({
    required this.totalMoneyLent,
    required this.totalOutstanding,
    required this.collectedToday,
    required this.activeLoans,
    required this.overdueLoans,
    required this.recentTransactions,
    required this.upcomingDues,
    required this.overdueLoanslist,
  });
}

/// Provider for dashboard data — aggregates all KPI values from cloud streams.
final dashboardDataProvider = StreamProvider<DashboardData>((ref) {
  final db = ref.watch(cloudDatabaseProvider);

  // Combine multiple streams from CloudDatabaseService using rxdart
  return Rx.combineLatest2(
    db.getLoans(),
    db.getPayments(),
    (List<Loan> loans, List<Payment> payments) {
      
      final totalLent = loans.fold(0.0, (sum, l) => sum + l.loanAmount);
      final totalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);
      final totalExpected = loans.fold(0.0, (sum, l) => sum + l.totalRepayable);
      
      final totalOutstanding = (totalExpected - totalPaid).clamp(0.0, double.infinity);
      
      final today = DateTime.now();
      final collectedToday = payments.where((p) => 
        p.paymentDate.year == today.year &&
        p.paymentDate.month == today.month &&
        p.paymentDate.day == today.day
      ).fold(0.0, (sum, p) => sum + p.amount);

      final active = loans.where((l) => l.statusName != 'closed').toList();
      final overdue = active.where((l) => l.isOverdue).toList();
      
      final upcoming = active.where((l) {
        if (l.isOverdue) return false;
        return l.daysUntilDue <= 7;
      }).toList();
      
      upcoming.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      return DashboardData(
        totalMoneyLent: totalLent,
        totalOutstanding: totalOutstanding,
        collectedToday: collectedToday,
        activeLoans: active.length,
        overdueLoans: overdue.length,
        recentTransactions: payments.take(10).toList(),
        upcomingDues: upcoming,
        overdueLoanslist: overdue,
      );
    },
  );
});

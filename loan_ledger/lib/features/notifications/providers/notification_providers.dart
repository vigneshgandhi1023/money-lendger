import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/storage_service.dart';
import '../../../models/loan.dart';

/// Notification items grouped by urgency.
class NotificationData {
  final List<Loan> dueToday;
  final List<Loan> dueTomorrow;
  final List<Loan> overdue;

  const NotificationData({
    required this.dueToday,
    required this.dueTomorrow,
    required this.overdue,
  });

  int get totalCount => dueToday.length + dueTomorrow.length + overdue.length;
}

/// Notification data provider.
final notificationDataProvider = Provider<NotificationData>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  final activeLoans = StorageService.getActiveLoans();

  final dueToday = activeLoans.where((loan) {
    final due = DateTime(loan.dueDate.year, loan.dueDate.month, loan.dueDate.day);
    return due.isAtSameMomentAs(today);
  }).toList();

  final dueTomorrow = activeLoans.where((loan) {
    final due = DateTime(loan.dueDate.year, loan.dueDate.month, loan.dueDate.day);
    return due.isAtSameMomentAs(tomorrow);
  }).toList();

  final overdue = StorageService.getOverdueLoans();

  return NotificationData(
    dueToday: dueToday,
    dueTomorrow: dueTomorrow,
    overdue: overdue,
  );
});

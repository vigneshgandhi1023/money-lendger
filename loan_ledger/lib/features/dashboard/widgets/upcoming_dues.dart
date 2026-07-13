import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/loan.dart';

/// Upcoming due payments section on the dashboard.
///
/// Shows loans due within the next 7 days with countdown badges.
class UpcomingDues extends StatelessWidget {
  final List<Loan> loans;

  const UpcomingDues({super.key, required this.loans});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loans.isEmpty) {
      return const EmptyState(
        icon: Icons.event_available_rounded,
        title: 'No upcoming dues',
        subtitle: 'All caught up! No payments due in the next 7 days',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Upcoming Due Payments',
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 12),
        ...loans.asMap().entries.map((entry) {
          final index = entry.key;
          final loan = entry.value;
          final customer = StorageService.getCustomer(loan.customerId);

          return GestureDetector(
            onTap: () => context.push('/loans/${loan.id}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getBorderColor(loan.daysUntilDue),
                ),
              ),
              child: Row(
                children: [
                  // Countdown badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getBadgeColor(loan.daysUntilDue),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          loan.daysUntilDue == 0
                              ? '!'
                              : '${loan.daysUntilDue}',
                          style: TextStyle(
                            color: _getBadgeTextColor(loan.daysUntilDue),
                            fontSize: loan.daysUntilDue == 0 ? 18 : 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (loan.daysUntilDue > 0)
                          Text(
                            'days',
                            style: TextStyle(
                              color: _getBadgeTextColor(loan.daysUntilDue),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer?.fullName ?? 'Unknown',
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormatter.formatDueStatus(loan.dueDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: loan.daysUntilDue <= 1
                                ? AppColors.warning
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.formatCompact(loan.remainingBalance),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'outstanding',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(
                duration: 300.ms,
                delay: Duration(milliseconds: index * 80),
              )
              .slideX(begin: 0.05, end: 0, duration: 300.ms);
        }),
      ],
    );
  }

  Color _getBorderColor(int days) {
    if (days <= 0) return AppColors.moneyOut.withValues(alpha: 0.3);
    if (days <= 2) return AppColors.warning.withValues(alpha: 0.3);
    return Colors.transparent;
  }

  Color _getBadgeColor(int days) {
    if (days <= 0) return AppColors.moneyOut.withValues(alpha: 0.12);
    if (days <= 2) return AppColors.warning.withValues(alpha: 0.12);
    return AppColors.info.withValues(alpha: 0.12);
  }

  Color _getBadgeTextColor(int days) {
    if (days <= 0) return AppColors.moneyOut;
    if (days <= 2) return AppColors.warning;
    return AppColors.info;
  }
}

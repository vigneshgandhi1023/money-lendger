import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/customer_avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/loan.dart';

/// Overdue customers section on the dashboard.
///
/// Lists customers with overdue loans, sorted by most overdue first.
class OverdueCustomers extends StatelessWidget {
  final List<Loan> overdueLoans;

  const OverdueCustomers({super.key, required this.overdueLoans});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (overdueLoans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.moneyOut, size: 18),
              const SizedBox(width: 6),
              Text(
                'Overdue Loans',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.moneyOut,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...overdueLoans.asMap().entries.map((entry) {
          final index = entry.key;
          final loan = entry.value;
          final customer = StorageService.getCustomer(loan.customerId);

          return GestureDetector(
            onTap: () => context.push('/loans/${loan.id}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? AppColors.moneyOutDark.withValues(alpha: 0.15)
                    : AppColors.moneyOutLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.moneyOut.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  CustomerAvatar(
                    name: customer?.fullName ?? '?',
                    photoPath: customer?.photoPath,
                    size: 40,
                    fontSize: 14,
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
                            color: AppColors.moneyOut,
                            fontWeight: FontWeight.w500,
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
                          color: AppColors.moneyOut,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'overdue',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.moneyOut.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms,
                  delay: Duration(milliseconds: index * 80))
              .slideX(begin: 0.05, end: 0, duration: 300.ms);
        }),
      ],
    );
  }
}

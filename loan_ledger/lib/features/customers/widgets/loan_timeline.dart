import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/loan.dart';

/// Loan timeline widget for customer detail.
///
/// Shows all loans for a customer in chronological order
/// as a visual timeline with status indicators.
class LoanTimeline extends StatelessWidget {
  final String customerId;

  const LoanTimeline({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loans = StorageService.getLoansForCustomer(customerId);

    if (loans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timeline_rounded,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'No loans yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text('Loan Timeline', style: theme.textTheme.titleMedium),
        ),
        ...loans.asMap().entries.map((entry) {
          final index = entry.key;
          final loan = entry.value;
          final isLast = index == loans.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline indicator
                SizedBox(
                  width: 30,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getDotColor(loan),
                          border: Border.all(
                            color: _getDotColor(loan),
                            width: 2,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: theme.colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                    ],
                  ),
                ),
                // Loan card
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/loans/${loan.id}'),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                CurrencyFormatter.format(loan.loanAmount),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              StatusChip(
                                status: loan.status,
                                isOverdue: loan.isOverdue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${DateFormatter.formatShort(loan.loanDate)} → ${DateFormatter.formatShort(loan.dueDate)}',
                            style: theme.textTheme.bodySmall,
                          ),
                          if (loan.remainingBalance > 0) ...[
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: loan.repaymentProgress,
                              minHeight: 3,
                              borderRadius: BorderRadius.circular(2),
                              backgroundColor:
                                  theme.colorScheme.outline.withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation(
                                _getDotColor(loan),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getDotColor(Loan loan) {
    if (loan.status == LoanStatus.closed) return AppColors.moneyIn;
    if (loan.isOverdue) return AppColors.moneyOut;
    return AppColors.info;
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/loan.dart';

/// Loan summary card for lists — compact version.
class LoanSummaryCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback? onTap;

  const LoanSummaryCard({super.key, required this.loan, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: _statusColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CurrencyFormatter.format(loan.loanAmount),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${loan.interestRate}% ${loan.interestType.suffix}',
                    style: theme.textTheme.bodySmall,
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
                    color: loan.remainingBalance > 0
                        ? AppColors.moneyOut
                        : AppColors.moneyIn,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  loan.remainingBalance > 0 ? 'remaining' : 'cleared',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor() {
    if (loan.status == LoanStatus.closed) return AppColors.moneyIn;
    if (loan.isOverdue) return AppColors.moneyOut;
    return AppColors.info;
  }
}

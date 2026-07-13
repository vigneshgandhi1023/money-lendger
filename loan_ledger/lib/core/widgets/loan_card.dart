import 'package:flutter/material.dart';

import '../../models/loan.dart';
import '../../models/enums.dart';
import '../theme/color_schemes.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

/// Compact loan summary card for lists.
///
/// Shows loan amount, outstanding balance, due date, status chip,
/// and a repayment progress indicator.
class LoanCard extends StatelessWidget {
  final Loan loan;
  final String? customerName;
  final VoidCallback? onTap;

  const LoanCard({
    super.key,
    required this.loan,
    this.customerName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: loan.isOverdue
                ? AppColors.moneyOut.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.4),
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Customer name + Status chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (customerName != null)
                  Expanded(
                    child: Text(
                      customerName!,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                _buildStatusChip(context),
              ],
            ),

            if (customerName != null) const SizedBox(height: 12),

            // Amount row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loan Amount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(loan.loanAmount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Outstanding',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(loan.remainingBalance),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: loan.remainingBalance > 0
                            ? AppColors.moneyOut
                            : AppColors.moneyIn,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: loan.repaymentProgress,
                minHeight: 4,
                backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(
                  loan.status == LoanStatus.closed
                      ? AppColors.moneyIn
                      : loan.isOverdue
                          ? AppColors.moneyOut
                          : theme.colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Bottom row: Due date + Interest
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormatter.formatDueStatus(loan.dueDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: loan.isOverdue
                        ? AppColors.moneyOut
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight:
                        loan.isOverdue ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                Text(
                  '${loan.interestRate}% ${loan.interestType.suffix}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    Color textColor;

    switch (loan.status) {
      case LoanStatus.active:
        chipColor = AppColors.info.withValues(alpha: 0.12);
        textColor = AppColors.info;
        break;
      case LoanStatus.overdue:
        chipColor = AppColors.moneyOut.withValues(alpha: 0.12);
        textColor = AppColors.moneyOut;
        break;
      case LoanStatus.closed:
        chipColor = AppColors.moneyIn.withValues(alpha: 0.12);
        textColor = AppColors.moneyIn;
        break;
    }

    // Override for dynamically detected overdue
    if (loan.isOverdue && loan.status != LoanStatus.closed) {
      chipColor = AppColors.moneyOut.withValues(alpha: 0.12);
      textColor = AppColors.moneyOut;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        loan.isOverdue && loan.status != LoanStatus.closed
            ? 'Overdue'
            : loan.status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

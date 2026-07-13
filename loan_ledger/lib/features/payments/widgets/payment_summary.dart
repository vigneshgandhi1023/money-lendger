import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/currency_formatter.dart';

/// Payment summary card showing before/after balances.
class PaymentSummary extends StatelessWidget {
  final double remainingBalance;
  final double paymentAmount;

  const PaymentSummary({
    super.key,
    required this.remainingBalance,
    required this.paymentAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final afterPayment = (remainingBalance - paymentAmount).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Remaining Balance',
            value: CurrencyFormatter.format(remainingBalance),
            valueColor: AppColors.moneyOut,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Payment Amount',
            value: '- ${CurrencyFormatter.format(paymentAmount)}',
            valueColor: AppColors.moneyIn,
          ),
          const SizedBox(height: 10),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'After Payment',
            value: CurrencyFormatter.format(afterPayment),
            valueColor: afterPayment <= 0 ? AppColors.moneyIn : null,
            isBold: true,
          ),
          if (afterPayment <= 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.moneyIn.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: AppColors.moneyIn, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Loan will be fully paid!',
                    style: TextStyle(
                      color: AppColors.moneyIn,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? theme.textTheme.titleSmall
              : theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: (isBold
                  ? theme.textTheme.titleMedium
                  : theme.textTheme.titleSmall)
              ?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

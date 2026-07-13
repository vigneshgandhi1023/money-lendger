import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../models/enums.dart';

/// Real-time interest calculator widget.
///
/// Shows the computed interest and total repayable amount
/// as the user fills in loan parameters.
class InterestCalculator extends StatelessWidget {
  final double? loanAmount;
  final double? interestRate;
  final InterestType interestType;
  final DateTime? loanDate;
  final DateTime? dueDate;

  const InterestCalculator({
    super.key,
    this.loanAmount,
    this.interestRate,
    this.interestType = InterestType.monthly,
    this.loanDate,
    this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loanAmount == null || interestRate == null || loanAmount! <= 0) {
      return const SizedBox.shrink();
    }

    final interest = _calculateInterest();
    final total = loanAmount! + interest;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calculation Preview',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _Row(label: 'Principal', value: CurrencyFormatter.format(loanAmount!)),
          const SizedBox(height: 6),
          _Row(
            label: 'Interest (${interestRate!}% ${interestType.suffix})',
            value: CurrencyFormatter.format(interest),
          ),
          const SizedBox(height: 8),
          Divider(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 8),
          _Row(
            label: 'Total Repayable',
            value: CurrencyFormatter.format(total),
            isBold: true,
          ),
        ],
      ),
    );
  }

  double _calculateInterest() {
    if (loanAmount == null || interestRate == null) return 0;

    switch (interestType) {
      case InterestType.flat:
        return loanAmount! * (interestRate! / 100);

      case InterestType.monthly:
        if (loanDate == null || dueDate == null) {
          return loanAmount! * (interestRate! / 100);
        }
        final months = (dueDate!.year - loanDate!.year) * 12 +
            (dueDate!.month - loanDate!.month);
        return loanAmount! * (interestRate! / 100) * months;

      case InterestType.yearly:
        if (loanDate == null || dueDate == null) {
          return loanAmount! * (interestRate! / 100);
        }
        final years = dueDate!.difference(loanDate!).inDays / 365.0;
        return loanAmount! * (interestRate! / 100) * years;
    }
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _Row({
    required this.label,
    required this.value,
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
          style: isBold
              ? theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/currency_formatter.dart';

/// Quick amount selection chips for the payment screen.
///
/// Provides one-tap shortcuts for 25%, 50%, 75%, and Full payment
/// to minimize taps during collection.
class QuickAmountChips extends StatelessWidget {
  final double remainingBalance;
  final ValueChanged<double> onSelect;
  final double? selectedAmount;

  const QuickAmountChips({
    super.key,
    required this.remainingBalance,
    required this.onSelect,
    this.selectedAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final amounts = [
      ('25%', remainingBalance * 0.25),
      ('50%', remainingBalance * 0.50),
      ('75%', remainingBalance * 0.75),
      ('Full', remainingBalance),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amounts.map((entry) {
        final label = entry.$1;
        final amount = entry.$2;
        final isSelected = selectedAmount != null &&
            (selectedAmount! - amount).abs() < 0.01;

        return GestureDetector(
          onTap: () => onSelect(amount),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.formatCompact(amount),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

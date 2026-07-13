import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/customer_avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/payment.dart';

/// Recent transactions list on the dashboard.
///
/// Shows the last 10 payments received with customer name,
/// amount, and relative date.
class RecentTransactions extends StatelessWidget {
  final List<Payment> payments;

  const RecentTransactions({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (payments.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'No transactions yet',
        subtitle: 'Payments will appear here as you collect them',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                '${payments.length} payments',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Transaction list
        ...payments.asMap().entries.map((entry) {
          final index = entry.key;
          final payment = entry.value;
          final customer = StorageService.getCustomer(payment.customerId);
          final customerName = customer?.fullName ?? 'Unknown';

          return _TransactionTile(
            customerName: customerName,
            amount: payment.amount,
            date: payment.paymentDate,
            notes: payment.notes,
            animationDelay: index * 50,
          );
        }),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String customerName;
  final double amount;
  final DateTime date;
  final String? notes;
  final int animationDelay;

  const _TransactionTile({
    required this.customerName,
    required this.amount,
    required this.date,
    this.notes,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CustomerAvatar(name: customerName, size: 40, fontSize: 14),

          const SizedBox(width: 12),

          // Name & date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.formatRelative(date),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '+ ${CurrencyFormatter.format(amount)}',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.moneyIn,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: animationDelay),
        )
        .slideX(
          begin: 0.05,
          end: 0,
          duration: 300.ms,
          delay: Duration(milliseconds: animationDelay),
        );
  }
}

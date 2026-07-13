import 'package:flutter/material.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/customer_avatar.dart';
import '../../../models/payment.dart';

/// Payment history widget for customer detail.
///
/// Shows a chronological list of all payments made by a customer
/// with date, amount, and associated loan info.
class PaymentHistory extends StatelessWidget {
  final String customerId;

  const PaymentHistory({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payments = StorageService.getPaymentsForCustomer(customerId);

    if (payments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'No payments received yet',
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
          child: Text(
            'Payment History',
            style: theme.textTheme.titleMedium,
          ),
        ),
        ...payments.map((payment) => _PaymentTile(payment: payment)),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final Payment payment;

  const _PaymentTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loan = StorageService.getLoan(payment.loanId);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Green checkmark icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.moneyIn.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_downward_rounded,
              color: AppColors.moneyIn,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormatter.format(payment.paymentDate),
                  style: theme.textTheme.titleSmall?.copyWith(fontSize: 13),
                ),
                if (payment.notes != null && payment.notes!.isNotEmpty)
                  Text(
                    payment.notes!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            '+ ${CurrencyFormatter.format(payment.amount)}',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.moneyIn,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

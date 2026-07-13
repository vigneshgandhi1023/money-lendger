import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/customer_avatar.dart';
import '../../../models/customer.dart';

/// Customer list card widget.
///
/// Compact card showing customer photo/initials, name, phone,
/// and outstanding balance preview.
class CustomerCard extends StatelessWidget {
  final Customer customer;
  final double totalBorrowed;
  final double totalPaid;
  final int activeLoans;
  final VoidCallback? onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.totalBorrowed,
    required this.totalPaid,
    required this.activeLoans,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = totalBorrowed - totalPaid;

    return GestureDetector(
      onTap: onTap ?? () => context.push('/customers/${customer.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.15 : 0.3,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CustomerAvatar(
              name: customer.fullName,
              photoPath: customer.photoPath,
              size: 48,
              fontSize: 16,
            ),

            const SizedBox(width: 14),

            // Name & phone
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.fullName,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        customer.phoneNumber,
                        style: theme.textTheme.bodySmall,
                      ),
                      if (activeLoans > 0) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$activeLoans loan${activeLoans > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Balance
            if (remaining > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatCompact(remaining),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.moneyOut,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'due',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                    ),
                  ),
                ],
              )
            else if (totalBorrowed > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.moneyIn.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Cleared',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.moneyIn,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

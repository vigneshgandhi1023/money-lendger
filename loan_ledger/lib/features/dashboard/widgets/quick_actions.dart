import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/widgets/quick_action_button.dart';

/// Quick action buttons row on the dashboard.
///
/// Provides one-tap access to: New Customer, New Loan, Receive Payment.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: QuickActionButton(
            label: 'New\nCustomer',
            icon: Icons.person_add_rounded,
            color: AppColors.primaryLight,
            onTap: () => context.push('/customers/add'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: QuickActionButton(
            label: 'New\nLoan',
            icon: Icons.add_card_rounded,
            color: AppColors.info,
            onTap: () => context.push('/loans/add'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: QuickActionButton(
            label: 'Receive\nPayment',
            icon: Icons.payments_rounded,
            color: AppColors.moneyIn,
            onTap: () => context.push('/payments/receive'),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 300.ms);
  }
}
